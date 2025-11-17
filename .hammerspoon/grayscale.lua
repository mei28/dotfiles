-- Toggle grayscale mode with Cmd + Shift + grayscale
-- caution: when the function is not toggled, check whether the content is only `color filter` is checked.
hs.hotkey.bind({ "cmd", "shift" }, "G", function()
	hs.eventtap.keyStroke({ "cmd", "alt", "fn" }, "F5")
end)
