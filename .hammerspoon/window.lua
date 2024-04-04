local M = {}

hs.window.animationDuration = 0
Units = {
  -- 半分分割
  right50     = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50      = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50       = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50       = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },

  -- 画面3分割設定
  right33     = { x = 0.66, y = 0.00, w = 0.34, h = 1.00 },
  left33      = { x = 0.00, y = 0.00, w = 0.33, h = 1.00 },
  center33    = { x = 0.33, y = 0.00, w = 0.33, h = 1.00 },

  -- 4分割
  lefttop     = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  righttop    = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  leftdown    = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  rightdown   = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },

  -- max,min
  max         = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  min         = { x = 0.33, y = 0.33, w = 0.33, h = 0.33 },

  -- 6分割
  right_up    = { x = 0.66, y = 0.00, w = 0.34, h = 0.50 },
  left_up     = { x = 0.00, y = 0.00, w = 0.33, h = 0.50 },
  center_up   = { x = 0.33, y = 0.00, w = 0.33, h = 0.50 },
  right_down  = { x = 0.66, y = 0.50, w = 0.34, h = 0.50 },
  left_down   = { x = 0.00, y = 0.50, w = 0.33, h = 0.50 },
  center_down = { x = 0.33, y = 0.50, w = 0.33, h = 0.50 },

  -- 画面2/3分割設定
  right66     = { x = 0.33, y = 0.00, w = 0.67, h = 1.00 },
  left66      = { x = 0.00, y = 0.00, w = 0.66, h = 1.00 },
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
Sash = { 'command', 'option', 'shift' }
hs.hotkey.bind(Sash, 'down', function() hs.window.focusedWindow():move(Units.center33, nil, true) end)
hs.hotkey.bind(Sash, 'left', function() hs.window.focusedWindow():move(Units.left33, nil, true) end)
hs.hotkey.bind(Sash, 'right', function() hs.window.focusedWindow():move(Units.right33, nil, true) end)
-- ６分割
hs.hotkey.bind(Sash, '1', function() hs.window.focusedWindow():move(Units.left_up, nil, true) end)
hs.hotkey.bind(Sash, '2', function() hs.window.focusedWindow():move(Units.center_up, nil, true) end)
hs.hotkey.bind(Sash, '3', function() hs.window.focusedWindow():move(Units.right_up, nil, true) end)
hs.hotkey.bind(Sash, '4', function() hs.window.focusedWindow():move(Units.left_down, nil, true) end)
hs.hotkey.bind(Sash, '5', function() hs.window.focusedWindow():move(Units.center_down, nil, true) end)
hs.hotkey.bind(Sash, '6', function() hs.window.focusedWindow():move(Units.right_down, nil, true) end)

-- 2/３分割
Sosh = { 'option', 'shift' }
hs.hotkey.bind(Sosh, 'left', function() hs.window.focusedWindow():move(Units.left66, nil, true) end)
hs.hotkey.bind(Sosh, 'right', function() hs.window.focusedWindow():move(Units.right66, nil, true) end)

-- {next, prev} window

function M.GetScreenWindowInfo()
  local focusedWindow = hs.window.focusedWindow()
  local focusedScreenFrame = focusedWindow:screen():frame()
  return focusedWindow, focusedScreenFrame
end

function M.MoveToNextScreen()
  local focusedWindow, focusedScreenFrame = M.GetScreenWindowInfo()
  local nextScreenFrame = focusedWindow:screen():next():frame()
  local windowFrame = focusedWindow:frame()

  -- Calculate the coordinates of the window frame in the next screen and retain aspect ratio
  local x, y, h, w = M.CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  windowFrame.x = x
  windowFrame.y = y
  windowFrame.w = w
  windowFrame.h = h

  -- Set the focused window's new frame dimensions
  focusedWindow:setFrame(windowFrame)
end

function M.CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  local x = (
    (((windowFrame.x - focusedScreenFrame.x) / focusedScreenFrame.w) * nextScreenFrame.w) + nextScreenFrame.x)
  local y = (
    (((windowFrame.y - focusedScreenFrame.y) / focusedScreenFrame.h) * nextScreenFrame.h) + nextScreenFrame.y)
  local h = ((windowFrame.h / focusedScreenFrame.h) * nextScreenFrame.h)
  local w = ((windowFrame.w / focusedScreenFrame.w) * nextScreenFrame.w)

  return x, y, h, w
end

function M.MoveToPrevScreen()
  -- Get the focused window, its window frame dimensions, its screen frame dimensions,
  -- and the next screen's frame dimensions.
  local focusedWindow, focusedScreenFrame = M.GetScreenWindowInfo()
  local nextScreenFrame = focusedWindow:screen():previous():frame()
  local windowFrame = focusedWindow:frame()

  -- Calculate the coordinates of the window frame in the next screen and retain aspect ratio
  local x, y, h, w = M.CalcNextWindowRatio(windowFrame, focusedScreenFrame, nextScreenFrame)
  windowFrame.x = x
  windowFrame.y = y
  windowFrame.w = w
  windowFrame.h = h

  -- Set the focused window's new frame dimensions
  focusedWindow:setFrame(windowFrame)
end

hs.hotkey.bind(Mash, "n", M.MoveToNextScreen)
hs.hotkey.bind(Mash, "p", M.MoveToPrevScreen)

-- window swicher
switcher = hs.window.switcher.new()
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = false
switcher.ui.showSelectedThumbnail = false
switcher.ui.thumbnailSize = 256
switcher.ui.backgroundColor = { 0.0, 0.0, 0.0, 0.0 }
hs.hotkey.bind({ 'alt' }, 'tab', function() switcher:next() end)
hs.hotkey.bind({ 'alt', 'shift' }, 'tab', function() switcher:previous() end)

return M
