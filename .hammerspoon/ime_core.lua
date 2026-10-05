-- Pure decision logic for Cmd-tap IME switching (left Cmd -> en, right Cmd -> jp).
-- No hs.* dependencies so it can be unit-tested with plain Lua; ime.lua wires it
-- to hs.eventtap and hs.keycodes.

local M = {}

-- macOS virtual key codes (kVK_Command, kVK_RightCommand)
local L_CMD = 55
local R_CMD = 54

function M.newCmdState()
	return {
		down = false, -- a Cmd key is currently held
		usedAsModifier = false, -- another key was pressed while Cmd was held
		pressedKeyCode = nil, -- which Cmd key started this press
		comboKeyCode = nil, -- first other key pressed while Cmd was held (for logging)
	}
end

-- Feed one event; returns "en" / "jp" when a switch should fire, else nil.
-- eventType: "flagsChanged" | "keyDown"; cmdFlag: whether the event's flags contain Cmd.
-- isKeyRepeat: true for autorepeat keyDown events.
function M.handleCmdEvent(state, eventType, keyCode, cmdFlag, isKeyRepeat)
	if eventType == "flagsChanged" and (keyCode == L_CMD or keyCode == R_CMD) then
		if cmdFlag then
			-- start of a Cmd press; ignore the second of a left+right double press
			if not state.down then
				state.down = true
				state.usedAsModifier = false
				state.pressedKeyCode = keyCode
			end
		else
			-- all Cmd keys released
			local decision = nil
			local reason = nil
			local comboKeyCode = nil
			if not state.down then
				reason = "notHeld" -- release without a matching press: press event never arrived
			elseif state.usedAsModifier then
				reason = "combo"
				comboKeyCode = state.comboKeyCode
			elseif state.pressedKeyCode == L_CMD then
				decision = "en"
			elseif state.pressedKeyCode == R_CMD then
				decision = "jp"
			end
			state.down = false
			state.usedAsModifier = false
			state.pressedKeyCode = nil
			state.comboKeyCode = nil
			return decision, reason, comboKeyCode
		end
	elseif eventType == "keyDown" and state.down then
		-- a fresh key press while Cmd is held makes this press a combination;
		-- autorepeat does not (it comes from a key held since before Cmd went down)
		if not isKeyRepeat then
			if not state.usedAsModifier then
				state.comboKeyCode = keyCode
			end
			state.usedAsModifier = true
		end
	end
	return nil
end

-- Decide what switching to `lang` requires, given what the system currently
-- reports. Returns setMethod (bool) and layout ("enable"|"disable"|nil).
-- Layout repair happens even when the method already matches: macOS tracks input
-- sources per application, so app switches change the method behind our back and
-- the remap state can be left inverted.
function M.planSwitch(lang, currentMethod, targetMethod, layoutEnabled)
	local setMethod = currentMethod ~= targetMethod
	local layout = nil
	if lang == "en" and layoutEnabled then
		layout = "disable"
	elseif lang == "jp" and not layoutEnabled then
		layout = "enable"
	end
	return setMethod, layout
end

return M
