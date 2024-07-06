-- https://www.joshmedeski.com/posts/customizing-yabai-with-lua/

-- Send message(s) to a running instance of yabai.
local function yabai(commands)
  for _, cmd in ipairs(commands) do
    os.execute("/opt/homebrew/bin/yabai -m " .. cmd)
  end
end

local function alt(key, commands)
  hs.hotkey.bind({ "alt" }, key, function()
    yabai(commands)
  end)
end

local function shift_alt(key, commands)
  hs.hotkey.bind({ "shift", "alt" }, key, function()
    yabai(commands)
  end)
end

local function shift_cmd(key, commands)
  hs.hotkey.bind({ "shift", "cmd" }, key, function()
    yabai(commands)
  end)
end

-- focus window
alt('h', { "window --focus west" })
alt('j', { "window --focus south" })
alt('k', { "window --focus north" })
alt('l', { "window --focus east" })
alt('n', { "window --focus stack.next" })
alt('p', { "window --focus stack.prev" })
alt('left', { "window --focus west" })
alt('down', { "window --focus south" })
alt('up', { "window --focus north" })
alt('right', { "window --focus east" })

-- move window

shift_alt('h', { 'window --warp west' })
shift_alt('j', { 'window --warp south' })
shift_alt('k', { 'window --warp north' })
shift_alt('l', { 'window --warp east' })

shift_alt("left", { 'window --warp west' })
shift_alt("down", { 'window --warp south' })
shift_alt("up", { 'window --warp north' })
shift_alt("right", { 'window --warp east' })

shift_alt('1', { 'window --space 1    ' })
shift_alt('2', { 'window --space 2    ' })
shift_alt('3', { 'window --space 3    ' })
shift_alt('4', { 'window --space 4    ' })
shift_alt('5', { 'window --space 5    ' })
shift_alt('9', { 'window --space prev ' })
shift_alt('0', { 'window --space next ' })

-- toggle window native fullscreen
shift_alt('f', { 'window --toggle native-fullscreen' })
-- toggle window fullscreen zoom
alt('f', { 'window --toggle zoom-fullscreen' })
-- float / unfloat window and restore position
shift_alt('space', { "window --toggle float && yabai -m window --grid 4:4:1:1:2:2" })


-- toggle window split type
alt('e', { 'window --toggle split' })

-- rotate tree
alt('r', { 'space --rotate 90' })
-- mirror tree y-axis
alt('y', { "space --mirror y-axis" })
-- mirror tree x-axis
alt('x', { 'space --mirror x-axis' })

-- restart yabai
-- from https://github.com/koekeishiya/yabai/wiki/Tips-and-tricks
-- (2022-10-11 21:24)
-- ctrl + alt + cmd - r : launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "r", function()
  os.execute("launchctl kickstart -k \"gui/${UID}/homebrew.mxcl.yabai\"")
end)


-- increase window size
shift_alt('a', { 'window --resize left:-20:0 ' })
shift_alt('s', { 'window --resize bottom:0:20' })
shift_alt('w', { 'window --resize top:0:-20  ' })
shift_alt('d', { 'window --resize right:20:0 ' })

-- decrease window size
shift_cmd('a', { "window --resize left:20:0    " })
shift_cmd('s', { "window --resize bottom:0:-20 " })
shift_cmd('w', { "window --resize top:0:20     " })
shift_cmd('d', { "window --resize right:-20:0  " })
