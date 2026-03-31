local Layout = {}
Layout.__index = Layout

-- Character to macOS keyCode mapping
local charToKeyCode = {
	q = 0x0c,
	w = 0x0d,
	e = 0x0e,
	r = 0x0f,
	t = 0x11,
	y = 0x10,
	u = 0x20,
	i = 0x22,
	o = 0x1f,
	p = 0x23,
	a = 0x00,
	s = 0x01,
	d = 0x02,
	f = 0x03,
	g = 0x05,
	h = 0x04,
	j = 0x26,
	k = 0x28,
	l = 0x25,
	[";"] = 0x29,
	z = 0x06,
	x = 0x07,
	c = 0x08,
	v = 0x09,
	b = 0x0b,
	n = 0x2d,
	m = 0x2e,
	[","] = 0x2b,
	["."] = 0x2f,
	["/"] = 0x2c,
}

-- QWERTY physical key positions per row
local qwertyRows = {
	{ "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
	{ "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" },
	{ "z", "x", "c", "v", "b", "n", "m", ",", ".", "/" },
}

-- Parse layout row strings into a keyCode-to-keyCode map
local function parseLayoutRows(rows)
	local keyMap = {}
	for rowIdx, row in ipairs(rows) do
		local keys = {}
		for key in row:gmatch("%S+") do
			table.insert(keys, key)
		end
		local qwertyRow = qwertyRows[rowIdx]
		if #keys ~= #qwertyRow then
			error(("Row %d: expected %d keys, got %d"):format(rowIdx, #qwertyRow, #keys))
		end
		for colIdx, targetKey in ipairs(keys) do
			local sourceChar = qwertyRow[colIdx]
			local sourceCode = charToKeyCode[sourceChar]
			local targetCode = charToKeyCode[targetKey]
			if not targetCode then
				error(("Unknown key '%s' in row %d"):format(targetKey, rowIdx))
			end
			keyMap[sourceCode] = targetCode
		end
	end
	return keyMap
end

-- Convert character list to keyCode set
local function parseShiftPassthrough(chars)
	if not chars then
		return {}
	end
	local set = {}
	for _, ch in ipairs(chars) do
		local code = charToKeyCode[ch]
		if code then
			set[code] = true
		end
	end
	return set
end

function Layout:new(name, rows, opts)
	opts = opts or {}
	local keyMap = parseLayoutRows(rows)
	local shiftPassthrough = parseShiftPassthrough(opts.shiftPassthrough)
	local reverseMap = {}
	for key, value in pairs(keyMap) do
		reverseMap[value] = key
	end
	return setmetatable({
		name = name,
		keyMap = keyMap,
		reverseMap = reverseMap,
		shiftPassthrough = shiftPassthrough,
		eventTap = nil,
		enabled = false,
	}, self)
end

function Layout:remapKey(event)
	if not self.enabled then
		return false
	end

	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local isKeyDown = event:getType() == hs.eventtap.event.types.keyDown

	-- Ctrlキーが押されている場合はリマップしない
	if flags.ctrl then
		return false
	end

	-- Skip remapping for keys marked as shift-passthrough
	if flags.shift and self.shiftPassthrough[keyCode] then
		return false
	end

	-- 通常の再マップ
	local remappedKeyCode = self.keyMap[keyCode]
	if remappedKeyCode then
		local mods = {}
		for _, mod in ipairs({ "shift", "ctrl", "alt", "cmd" }) do
			if flags[mod] then
				table.insert(mods, mod)
			end
		end

		local newEventDown = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, true)
		local newEventUp = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, false)
		return true, { newEventDown, newEventUp }
	end

	return false
end

function Layout:isEnabled()
	return self.enabled
end

function Layout:enableLayout()
	if not self.eventTap then
		self.eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
			return self:remapKey(event)
		end)
	end
	self.enabled = true
	self.eventTap:start()
end

function Layout:disableLayout()
	if self.eventTap then
		self.eventTap:stop()
	end
	self.enabled = false
end

function Layout:toggleLayout()
	if self.enabled then
		self:disableLayout()
	else
		self:enableLayout()
	end
end

return Layout
