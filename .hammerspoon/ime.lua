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

-- Detect English input method (Apple 日本語 IME 入りなら Romaji、無ければ ABC/U.S.)
local function detectEnglishMethod()
	local preferred = { "Romaji", "ABC", "U.S.", "English (US)" }
	local available = hs.keycodes.methods()
	for _, want in ipairs(preferred) do
		for _, method in ipairs(available) do
			if method == want then
				return want
			end
		end
	end
	return "ABC"
end

local jpMethod, jpDisplayName = detectJapaneseMethod()
local enMethod = detectEnglishMethod()

local config = {
	showtime = 0.2,
	layout = "ebi", -- Default layout
	inputMethods = { en = enMethod, jp = jpMethod },
	displayName = { en = "ABC", jp = jpDisplayName },
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

-- Helper function to switch input method
local function switchInputMethod(lang)
	local current = hs.keycodes.currentMethod()
	local setMethod, layout = core.planSwitch(lang, current, config.inputMethods[lang], config.module:isEnabled())

	local app = hs.application.frontmostApplication()
	logDebug(string.format(
		"switch %s: currentMethod=%s setMethod=%s layout=%s app=%s secure=%s",
		lang,
		tostring(current),
		tostring(setMethod),
		tostring(layout),
		app and app:name() or "?",
		tostring(hs.eventtap.isSecureInputEnabled())
	))

	if setMethod then
		hs.keycodes.setMethod(config.inputMethods[lang])
		hs.alert.show(config.displayName[lang], hs.styledtext, hs.screen.mainScreen(), config.showtime)
	end

	if layout == "disable" then
		config.module:disableLayout()
		hs.alert.show(config.module.name .. " OFF", hs.screen.mainScreen(), config.showtime)
	elseif layout == "enable" then
		config.module:enableLayout()
		hs.alert.show(config.module.name .. " ON", hs.screen.mainScreen(), config.showtime)
	end
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
