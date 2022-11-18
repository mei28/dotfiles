hs.window.animationDuration = 0
units = {
  -- 半分分割
  right50  = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50   = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50    = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50    = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },

  -- 画面3分割設定
  right33  = { x = 0.66, y = 0.00, w = 0.34, h = 1.00 },
  left33   = { x = 0.00, y = 0.00, w = 0.33, h = 1.00 },
  center33 = { x = 0.33, y = 0.00, w = 0.33, h = 1.00 },

  -- 4分割
  lefttop  = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  righttop = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  leftdown = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  leftdown = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },

  -- max,min
  max      = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  min      = { x = 0.33, y = 0.33, w = 0.33, h = 0.33 },
}

-- 半分分割
mash = { 'command', 'option' }
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'left', function() hs.window.focusedWindow():move(units.left50, nil, true) end)
-- 4分割
hs.hotkey.bind(mash, '1', function() hs.window.focusedWindow():move(units.lefttop, nil, true) end)
hs.hotkey.bind(mash, '2', function() hs.window.focusedWindow():move(units.righttop, nil, true) end)
hs.hotkey.bind(mash, '3', function() hs.window.focusedWindow():move(units.leftdown, nil, true) end)
hs.hotkey.bind(mash, '4', function() hs.window.focusedWindow():move(units.rightdown, nil, true) end)
-- max
hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.max, nil, true) end)
-- min
hs.hotkey.bind(mash, 'n', function() hs.window.focusedWindow():move(units.min, nil, true) end)
-- ３分割
mash = { 'command', 'option', 'shift'}
hs.hotkey.bind(mash, 'down', function() hs.window.focusedWindow():move(units.center33, nil, true) end)
hs.hotkey.bind(mash, 'left', function() hs.window.focusedWindow():move(units.left33, nil, true) end)
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right33, nil, true) end)
