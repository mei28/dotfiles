-- Pure decision logic for Cmd-tap IME switching (left Cmd -> en, right Cmd -> jp).
-- No hs.* dependencies so it can be unit-tested with plain Lua; ime.lua wires it
-- to hs.eventtap and hs.keycodes.

local M = {}

-- macOS virtual key codes (kVK_Command, kVK_RightCommand)
local L_CMD = 55
local R_CMD = 54

-- Per-key press state. The two Cmd keys are tracked independently because
-- flags alone cannot tell "pressed" from "released while the other Cmd is
-- held" apart (both arrive with the cmd flag set); what separates them is
-- that consecutive flagsChanged events for ONE keyCode alternate
-- press/release, so each key's event stream is parsed on its own.
local function newKeyState()
	return {
		down = false, -- this Cmd key is currently held
		usedAsModifier = false, -- another key was pressed while this Cmd was held
		comboKeyCode = nil, -- first other key pressed while held (for logging)
	}
end

function M.newCmdState()
	return {
		[L_CMD] = newKeyState(),
		[R_CMD] = newKeyState(),
		eligible = nil, -- keyCode of the press allowed to fire a switch (see below)
	}
end

-- Feed one event; returns "en" / "jp" when a switch should fire, else nil.
-- eventType: "flagsChanged" | "keyDown"; cmdFlag: whether the event's flags
-- contain Cmd (aggregate across left and right).
-- isKeyRepeat: true for autorepeat keyDown events.
--
-- Only the FIRST press of an overlap (a roll across both Cmd keys) is
-- switch-eligible: firing on every release would send TIS two input-source
-- switches within milliseconds, and rapid back-to-back switches are exactly
-- what leaves apps stuck in the previous source. The eligible key fires on
-- its release; the later press's release reports "secondary".
function M.handleCmdEvent(state, eventType, keyCode, cmdFlag, isKeyRepeat)
	if eventType == "flagsChanged" and (keyCode == L_CMD or keyCode == R_CMD) then
		local key = state[keyCode]
		if not key.down then
			-- a press-shaped event starts a press; a release-shaped event with no
			-- matching press means the key-down event never arrived
			if not cmdFlag then
				return nil, "notHeld"
			end
			key.down = true
			key.usedAsModifier = false
			key.comboKeyCode = nil
			if state.eligible == nil then
				state.eligible = keyCode
			end
		else
			-- the key is down, so this flagsChanged is its release. cmdFlag may
			-- still be true when the other Cmd is still held.
			local decision = nil
			local reason = nil
			local comboKeyCode = nil
			if keyCode ~= state.eligible then
				reason = "secondary" -- rolled onto while another Cmd was held; first press wins
			elseif key.usedAsModifier then
				reason = "combo"
				comboKeyCode = key.comboKeyCode
			elseif keyCode == L_CMD then
				decision = "en"
			else
				decision = "jp"
			end
			if keyCode == state.eligible then
				state.eligible = nil
			end
			key.down = false
			key.usedAsModifier = false
			key.comboKeyCode = nil
			return decision, reason, comboKeyCode
		end
	elseif eventType == "keyDown" then
		-- a fresh key press while a Cmd is held makes THAT Cmd's press a
		-- combination; autorepeat does not (it comes from a key held since
		-- before Cmd went down)
		if not isKeyRepeat then
			for _, cmdKeyCode in ipairs({ L_CMD, R_CMD }) do
				local key = state[cmdKeyCode]
				if key.down then
					if not key.usedAsModifier then
						key.comboKeyCode = keyCode
					end
					key.usedAsModifier = true
				end
			end
		end
	end
	return nil
end

-- Pick the first name from `preferred` that is present in `available`.
-- Returns `fallback` (possibly nil) when none match.
-- Callers must search the right category: keyboard layouts (ABC, U.S.) only
-- appear in hs.keycodes.layouts(), never in methods() (Hammerspoon #1022),
-- which is why the English target must be picked from layouts().
function M.pickByPreference(available, preferred, fallback)
	for _, want in ipairs(preferred) do
		for _, name in ipairs(available) do
			if name == want then
				return name
			end
		end
	end
	return fallback
end

-- Is the system already on the target?
-- target = { name = ..., kind = "layout"|"method" }.
-- currentMethod: hs.keycodes.currentMethod() (nil while a plain layout is
-- selected). currentLayout: hs.keycodes.currentLayout().
-- WARNING: currentLayout() cannot be the match criterion on its own — TIS
-- keeps the "current layout" slot independent of method selection, so it
-- reports ABC even while a Japanese method source is active (observed
-- 2026-10-08; checking it made the switch decision never fire). A plain
-- layout counts as reached only when no IME method is active AND the layout
-- name matches.
function M.inputMatches(target, currentMethod, currentLayout)
	if target.kind == "layout" then
		return currentMethod == nil and currentLayout == target.name
	end
	return currentMethod == target.name
end

-- Decide what switching to `lang` requires, given what the system currently
-- reports. Returns needsSwitch (bool) and layout ("enable"|"disable"|nil).
-- Layout repair happens even when the source already matches: macOS tracks
-- input sources per application, so app switches change the source behind
-- our back and the remap state can be left inverted.
function M.planSwitch(lang, currentMethod, currentLayout, target, layoutEnabled)
	local needsSwitch = not M.inputMatches(target, currentMethod, currentLayout)
	local layout = nil
	if lang == "en" and layoutEnabled then
		layout = "disable"
	elseif lang == "jp" and not layoutEnabled then
		layout = "enable"
	end
	return needsSwitch, layout
end

-- Post-switch verification. macOS's TIS input-source selection can report
-- success while the app keeps typing in the previous source, so callers
-- re-read the method shortly after switching and consult this.
function M.newVerifyState()
	return { retries = 0 }
end

-- matches: whether the re-read method equals the requested target.
-- Returns "ok" (state converged), "retry" (switch again), or "giveup"
-- (out of retries; surface the failure instead of looping forever).
function M.verifyResult(state, matches, maxRetries)
	if matches then
		return "ok"
	end
	if state.retries >= maxRetries then
		return "giveup"
	end
	state.retries = state.retries + 1
	return "retry"
end

return M
