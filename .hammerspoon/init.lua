hs.window.animationDuration = 0
Units = {
  -- 半分分割
  right50 = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50  = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50   = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50   = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },

  -- 画面3分割設定
  right33  = { x = 0.66, y = 0.00, w = 0.33, h = 1.00 },
  left33   = { x = 0.00, y = 0.00, w = 0.33, h = 1.00 },
  center33 = { x = 0.33, y = 0.00, w = 0.33, h = 1.00 },

  -- 4分割
  lefttop   = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  righttop  = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  leftdown  = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  rightdown = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },

  -- max,min
  max = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  min = { x = 0.33, y = 0.33, w = 0.33, h = 0.33 },

}

-- 半分分割
Mash = { 'command', 'option' }
hs.hotkey.bind(Mash, 'right', function() hs.window.focusedWindow():move(Units.right50, nil, true) end)
hs.hotkey.bind(Mash, 'left', function() hs.window.focusedWindow():move(Units.left50, nil, true) end)
hs.hotkey.bind(Mash, 'up', function() hs.window.focusedWindow():move(Units.top50, nil, true) end)
hs.hotkey.bind(Mash, 'down', function() hs.window.focusedWindow():move(Units.bot50, nil, true) end)
-- 4分割
hs.hotkey.bind(Mash, '1', function() hs.window.focusedWindow():move(Units.lefttop, nil, true) end)
hs.hotkey.bind(Mash, '2', function() hs.window.focusedWindow():move(Units.righttop, nil, true) end)
hs.hotkey.bind(Mash, '3', function() hs.window.focusedWindow():move(Units.leftdown, nil, true) end)
hs.hotkey.bind(Mash, '4', function() hs.window.focusedWindow():move(Units.rightdown, nil, true) end)
-- max
hs.hotkey.bind(Mash, 'm', function() hs.window.focusedWindow():move(Units.max, nil, true) end)
-- min
hs.hotkey.bind(Mash, 'c', function() hs.window.focusedWindow():move(Units.min, nil, true) end)
-- ３分割
Mash = { 'command', 'option', 'shift' }
hs.hotkey.bind(Mash, 'down', function() hs.window.focusedWindow():move(Units.center33, nil, true) end)
hs.hotkey.bind(Mash, 'left', function() hs.window.focusedWindow():move(Units.left33, nil, true) end)
hs.hotkey.bind(Mash, 'right', function() hs.window.focusedWindow():move(Units.right33, nil, true) end)

-- {next, prev} window
Mash = { 'command', 'option' }

function GetScreenWindowInfo()
  local focusedWindow = hs.window.focusedWindow()
  local focusedScreenFrame = focusedWindow:screen():frame()
  return focusedWindow, focusedScreenFrame

end

function MoveToNextScreen()
  local focusedWindow, focusedScreenFrame = GetScreenWindowInfo()
  local nextScreenFrame = focusedWindow:screen():next():frame()
  local windowFrame = focusedWindow:frame()

  -- Calculate the coordinates of the window frame in the next screen and retain aspect ratio
  local x, y, h, w = CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  windowFrame.x = x
  windowFrame.y = y
  windowFrame.w = w
  windowFrame.h = h

  -- Set the focused window's new frame dimensions
  focusedWindow:setFrame(windowFrame)
end

function CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  local x = (
      (((windowFrame.x - focusedScreenFrame.x) / focusedScreenFrame.w) * nextScreenFrame.w) + nextScreenFrame.x)
  local y = (
      (((windowFrame.y - focusedScreenFrame.y) / focusedScreenFrame.h) * nextScreenFrame.h) + nextScreenFrame.y)
  local h = ((windowFrame.h / focusedScreenFrame.h) * nextScreenFrame.h)
  local w = ((windowFrame.w / focusedScreenFrame.w) * nextScreenFrame.w)

  return x, y, h, w
end

function MoveToPrevScreen()
  -- Get the focused window, its window frame dimensions, its screen frame dimensions,
  -- and the next screen's frame dimensions.
  local focusedWindow, focusedScreenFrame = getScreenWindowInfo()
  local nextScreenFrame = focusedWindow:screen():previous():frame()
  local windowFrame = focusedWindow:frame()

  -- Calculate the coordinates of the window frame in the next screen and retain aspect ratio
  local x, y, h, w = CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  windowFrame.x = x
  windowFrame.y = y
  windowFrame.w = w
  windowFrame.h = h

  -- Set the focused window's new frame dimensions
  focusedWindow:setFrame(windowFrame)
end

hs.hotkey.bind(Mash, "n", MoveToNextScreen)
hs.hotkey.bind(Mash, "p", MoveToPrevScreen)

-- like karabiner
SimpleCmd = false
function EikanaEvent(event)
  Map = hs.keycodes.map
  KeyCode = event:getKeyCode()
  Flag = event:getFlags()
  if event:getType() == hs.eventtap.event.types.keyDown then
    if Flag['cmd'] then
      SimpleCmd = true
    end
  elseif event:getType() == hs.eventtap.event.types.flagsChanged then
    if not Flag['cmd'] then
      if SimpleCmd == false then
        if KeyCode == Map['cmd'] then
          hs.keycodes.setMethod('Romaji')
        elseif KeyCode == Map['rightcmd'] then
          hs.keycodes.setMethod('Hiragana')
        else
          hs.keycodes.setMethod('Romaji')
        end
      end
      SimpleCmd = false
    end
  end
end

Eikana = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged }, EikanaEvent)
Eikana:start()

-- visible key
-- hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.systemDefined },
--   function(event)
--     local type = event:getType()
--     if type == hs.eventtap.event.types.keyDown then
--       print(hs.keycodes.map[event:getKeyCode()])
--     elseif type == hs.eventtap.event.types.systemDefined then
--       local t = event:systemKey()
--       if t.down then
--         print("System key: " .. t.key)
--       end
--     end
--   end):start()
