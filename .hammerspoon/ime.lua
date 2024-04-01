local eucalyn = require('eucalyn')

-- like karabiner
SimpleCmd = false
function EikanaEvent(event)
  Map = hs.keycodes.map
  KeyCode = event:getKeyCode()
  Flag = event:getFlags()
  if event:getType() == hs.eventtap.event.types.keyUp then
    if Flag['cmd'] then
      SimpleCmd = true
    end
  elseif event:getType() == hs.eventtap.event.types.flagsChanged then
    if not Flag['cmd'] then
      if SimpleCmd == false then
        if KeyCode == Map['cmd'] then
          if hs.keycodes.currentMethod() ~= 'Romaji' then
            hs.keycodes.setMethod('Romaji')
            hs.alert.show("ABC", hs.styledtext, hs.screen.mainScreen(), 0.2)
            eucalyn.disableEucalynLayout()
            hs.alert.show("Eucalyn OFF", hs.screen.mainScreen(), 0.2)
          end
        elseif KeyCode == Map['rightcmd'] then
          if hs.keycodes.currentMethod() ~= 'Hiragana' then
            hs.keycodes.setMethod('Hiragana')
            hs.alert.show("かな", hs.styledtext, hs.screen.mainScreen(), 0.2)
          end
          -- eucalyn
          eucalyn.toggleEucalynLayout()
          if eucalyn.isEnabled() then
            hs.alert.show("Eucalyn ON", hs.screen.mainScreen(), 0.2)
          else
            hs.alert.show("Eucalyn OFF", hs.screen.mainScreen(), 0.2)
          end

        end
      end
      SimpleCmd = false
    end
  end
end

Eikana = hs.eventtap.new({ hs.eventtap.event.types.keyUp, hs.eventtap.event.types.flagsChanged }, EikanaEvent)
Eikana:start()

local function Esc2Eng(event)
  local c = event:getKeyCode()
  if c == hs.keycodes.map['escape'] then
    if hs.keycodes.currentMethod() ~= 'Romaji' then
      hs.keycodes.setMethod('Romaji')
      hs.alert.show("ABC", hs.styledtext, hs.screen.mainScreen(), 0.2)
      -- eucalyn
      eucalyn.disableEucalynLayout()
      hs.alert.show("Eucalyn OFF", hs.screen.mainScreen(), 0.2)
    end
  end
end

Esc2EngEvent = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, Esc2Eng)
Esc2EngEvent:start()

-- eucalyn
local function toggleEucalynLayout()
  eucalyn.toggleEucalynLayout()
  if eucalyn.isEnabled() then
    hs.alert.show("Eucalyn ON", hs.screen.mainScreen(), 0.2)
  else
    hs.alert.show("Eucalyn OFF", hs.screen.mainScreen(), 0.2)
  end
end

hs.hotkey.bind({ 'alt', 'ctrl' }, 'e', toggleEucalynLayout)
hs.hotkey.bind({ 'alt', 'ctrl' }, 'd', toggleEucalynLayout)
hs.hotkey.bind({ 'alt', 'ctrl' }, ',', toggleEucalynLayout)
