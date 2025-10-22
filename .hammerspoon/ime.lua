local layouts = {
  eucalyn = require('eucalyn'),
  oonishi = require('oonishi'),
  ebi = require('ebi'),
  qwerty = require('qwerty'),
}

local config = {
  showtime = 0.2,
  layout = 'ebi', -- Default layout
  inputMethods = { en = "Romaji", jp = "Hiragana" },
  displayName = { en = "ABC", jp = "かな" },
}

-- Validate and initialize layout
if not layouts[config.layout] then
  error("Invalid layout specified: " .. config.layout)
end
config.module = layouts[config.layout]

local isSimpleCmd = false

-- Helper function to switch input method
local function switchInputMethod(lang)
  if hs.keycodes.currentMethod() ~= config.inputMethods[lang] then
    hs.keycodes.setMethod(config.inputMethods[lang])
    hs.alert.show(config.displayName[lang], hs.styledtext, hs.screen.mainScreen(), config.showtime)

    if lang == "en" then
      -- config.module:disableLayout()
      hs.alert.show(config.module.name .. " OFF", hs.screen.mainScreen(), config.showtime)
    elseif lang == "jp" then
      config.module:enableLayout()
      hs.alert.show(config.module.name .. " ON", hs.screen.mainScreen(), config.showtime)
    end
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

-- Event handler for key and flag changes
local function EikanaEvent(event)
  local map = hs.keycodes.map
  local keyCode = event:getKeyCode()
  local flags = event:getFlags()

  if event:getType() == hs.eventtap.event.types.keyUp then
    if flags["cmd"] then
      isSimpleCmd = true
    end
  elseif event:getType() == hs.eventtap.event.types.flagsChanged then
    if not flags["cmd"] and not isSimpleCmd then
      if keyCode == map["cmd"] then
        switchInputMethod("en")
      elseif keyCode == map["rightcmd"] then
        switchInputMethod("jp")
      end
    end
    isSimpleCmd = false
  end
end

Eikana = hs.eventtap.new({ hs.eventtap.event.types.keyUp, hs.eventtap.event.types.flagsChanged }, EikanaEvent)
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
hs.hotkey.bind({ "ctrl", "alt" }, "3", function() changeLayout("eucalyn") end)
hs.hotkey.bind({ "ctrl", "alt" }, "2", function() changeLayout("oonishi") end)
hs.hotkey.bind({ "ctrl", "alt" }, "1", function() changeLayout("ebi") end)
hs.hotkey.bind({ "ctrl", "alt" }, "0", function() changeLayout("qwerty") end)
