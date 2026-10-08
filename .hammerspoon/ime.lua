local layouts = {
	eucalyn = require("eucalyn"),
	oonishi = require("oonishi"),
	ebi = require("ebi"),
	qwerty = require("qwerty"),
	waddlier = require("waddlier"),
}

local core = require("ime_core")

-- Detect Japanese input method (prefer azooKey if available)
local function detectJapaneseMethod()
	local azooKeyName = "azooKey (日本語)"
	for _, method in ipairs(hs.keycodes.methods()) do
		if method == azooKeyName then
			return azooKeyName, "azooKey"
		end
	end
	return "Hiragana", "かな", "Japanese"
end

-- Detect the English input target: prefer a real keyboard LAYOUT (ABC/U.S.)
-- over Romaji. Romaji is a mode INSIDE the Japanese IME (Kotoeri), and
-- switching between two modes of one input method is unreliable — TIS
-- reports the new selection but apps keep typing in the previous mode
-- (observed 2026-10-08: "display says hiragana but romaji comes out"). A
-- layout<->method switch does not hit this. Layouts must be looked up in
-- hs.keycodes.layouts(); methods() never lists them (Hammerspoon #1022).
local function detectEnglishTarget()
	local layout = core.pickByPreference(hs.keycodes.layouts(), { "ABC", "U.S.", "English (US)" })
	if layout then
		return layout, "layout"
	end
	-- no separate English layout enabled: fall back to the IME's Romaji mode
	return core.pickByPreference(hs.keycodes.methods(), { "Romaji" }, "Romaji"), "method"
end

local jpMethod, jpDisplayName = detectJapaneseMethod()
local enName, enKind = detectEnglishTarget()

local function setInputTarget(target)
	if target.kind == "layout" then
		hs.keycodes.setLayout(target.name)
	else
		hs.keycodes.setMethod(target.name)
	end
end

local config = {
	showtime = 0.2,
	layout = "ebi", -- Default layout
	targets = { en = { name = enName, kind = enKind }, jp = { name = jpMethod, kind = "method" } },
	displayName = { en = enName, jp = jpDisplayName },
	-- Decision log for diagnosing missed switches; flip to false once stable.
	debug = true,
}

local debugLogPath = os.getenv("HOME") .. "/.hammerspoon_ime_debug.log"

local function logDebug(msg)
	if not config.debug then
		return
	end
	local f = io.open(debugLogPath, "a")
	if f then
		f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\n")
		f:close()
	end
end

-- Validate and initialize layout
if not layouts[config.layout] then
	error("Invalid layout specified: " .. config.layout)
end
config.module = layouts[config.layout]

-- Post-switch verification: TIS can report a successful selection while the
-- app keeps typing in the previous source (observed 2026-10-08), so re-read
-- the current source shortly after a switch and retry on mismatch. The timer
-- must be a global or it gets garbage-collected before firing.
local VERIFY_DELAY = 0.25
local VERIFY_MAX_RETRIES = 2
VerifyTimer = nil

-- forward declaration: scheduleVerify retries by calling the switch again
local switchInputMethod

local function scheduleVerify(lang, verifyState)
	if VerifyTimer then
		VerifyTimer:stop() -- debounce: only the latest switch gets verified
	end
	VerifyTimer = hs.timer.doAfter(VERIFY_DELAY, function()
		local currentMethod = hs.keycodes.currentMethod()
		local currentLayout = hs.keycodes.currentLayout()
		local verdict = core.verifyResult(verifyState,
			core.inputMatches(config.targets[lang], currentMethod, currentLayout), VERIFY_MAX_RETRIES)
		if verdict == "ok" then
			return
		end
		logDebug(string.format("verify %s: lang=%s method=%s layout=%s retries=%d",
			verdict, lang, tostring(currentMethod), tostring(currentLayout), verifyState.retries))
		if verdict == "giveup" then
			hs.alert.show("IME switch failed (" .. lang .. ")", 1.0)
			return
		end
		switchInputMethod(lang, verifyState)
	end)
end

-- Helper function to switch input method. verifyState is set only on
-- verification retries so the retry budget is shared across the retries.
function switchInputMethod(lang, verifyState)
	local target = config.targets[lang]
	local currentMethod = hs.keycodes.currentMethod()
	local currentLayout = hs.keycodes.currentLayout()
	local needsSwitch, layout =
		core.planSwitch(lang, currentMethod, currentLayout, target, config.module:isEnabled())

	local app = hs.application.frontmostApplication()
	logDebug(string.format(
		"switch %s: method=%s layout=%s src=%s target=%s(%s) needsSwitch=%s layoutOp=%s app=%s secure=%s",
		lang,
		tostring(currentMethod),
		tostring(currentLayout),
		tostring(hs.keycodes.currentSourceID()),
		target.name,
		target.kind,
		tostring(needsSwitch),
		tostring(layout),
		app and app:name() or "?",
		tostring(hs.eventtap.isSecureInputEnabled())
	))

	if needsSwitch then
		setInputTarget(target)
		hs.alert.show(config.displayName[lang], hs.styledtext, hs.screen.mainScreen(), config.showtime)
	end

	if layout == "disable" then
		config.module:disableLayout()
		hs.alert.show(config.module.name .. " OFF", hs.screen.mainScreen(), config.showtime)
	elseif layout == "enable" then
		config.module:enableLayout()
		hs.alert.show(config.module.name .. " ON", hs.screen.mainScreen(), config.showtime)
	end

	scheduleVerify(lang, verifyState or core.newVerifyState())
end

-- Helper function to change layout
local function changeLayout(newLayout)
	if layouts[newLayout] then
		config.module:disableLayout()
		-- hs.alert.show(config.module.name .. " OFF", hs.screen.mainScreen(), config.showtime)

		config.layout = newLayout
		config.module = layouts[newLayout]

		config.module:enableLayout()
		hs.alert.show(config.module.name .. " ON", hs.screen.mainScreen(), config.showtime)
	else
		hs.alert.show("Invalid layout: " .. newLayout, hs.screen.mainScreen(), config.showtime)
	end
end

-- Record secure-input transitions: while secure input is on, macOS stops
-- delivering keyboard events to event taps, which shows up in the log as a
-- silent gap that looks like "switching died" (observed 2026-10-08).
local lastSecure = nil
-- hs.timer objects are garbage-collected unless a reference is kept, so this
-- must be a global like Eikana / Esc2EngEvent below
SecureInputPoller = hs.timer.doEvery(10, function()
	if not config.debug then
		return
	end
	local secure = hs.eventtap.isSecureInputEnabled()
	if secure ~= lastSecure then
		lastSecure = secure
		local app = hs.application.frontmostApplication()
		logDebug(string.format("secure input: %s app=%s", tostring(secure), app and app:name() or "?"))
	end
end)

-- Event handler for key and flag changes.
-- keyDown-based combination detection in ime_core: any other key's keyDown while
-- Cmd is held marks the press as a combination, so the result no longer depends
-- on whether you release Cmd or the other key first.
local cmdState = core.newCmdState()
local map = hs.keycodes.map

local function EikanaEvent(event)
	local types = hs.eventtap.event.types
	local eventType = event:getType()
	local kind
	if eventType == types.flagsChanged then
		kind = "flagsChanged"
	elseif eventType == types.keyDown then
		kind = "keyDown"
	else
		return
	end

	local keyCode = event:getKeyCode()
	local isKeyRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) == 1
	local decision, reason, comboKeyCode =
		core.handleCmdEvent(cmdState, kind, keyCode, event:getFlags()["cmd"] and true or false, isKeyRepeat)

	if decision then
		logDebug(string.format("cmd tap: key=%d decide=%s", keyCode, decision))
		switchInputMethod(decision)
	elseif reason then
		-- combo: which key turned it into a combination; notHeld: the press event never arrived
		local comboLabel = comboKeyCode and string.format(" comboKey=%s(%d)", tostring(map[comboKeyCode]), comboKeyCode) or ""
		logDebug(string.format("cmd tap: key=%d ignored (%s%s)", keyCode, reason, comboLabel))
	end
end

Eikana = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged }, EikanaEvent)
Eikana:start()

-- Event handler for Escape key to switch to English
local function Esc2Eng(event)
	if event:getKeyCode() == hs.keycodes.map["escape"] then
		switchInputMethod("en")
	end
end

Esc2EngEvent = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, Esc2Eng)
Esc2EngEvent:start()

-- Hotkey bindings for changing layouts
hs.hotkey.bind({ "ctrl", "alt" }, "4", function()
	changeLayout("waddlier")
end)
hs.hotkey.bind({ "ctrl", "alt" }, "3", function()
	changeLayout("eucalyn")
end)
hs.hotkey.bind({ "ctrl", "alt" }, "2", function()
	changeLayout("oonishi")
end)
hs.hotkey.bind({ "ctrl", "alt" }, "1", function()
	changeLayout("ebi")
end)
hs.hotkey.bind({ "ctrl", "alt" }, "0", function()
	changeLayout("qwerty")
end)
