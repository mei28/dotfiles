local wezterm = require("wezterm")

local DEFAULT_FG = { Color = "#9a9eab" }
local DEFAULT_BG = { Color = "#333333" }

local SPACE_1 = " "
local SPACE_3 = "   "

-- local HEADER_HOST = { Foreground = { Color = '#75b1a9' }, Text = '' }
local HEADER_CWD = { Foreground = { Color = "#92aac7" }, Text = "" }
local HEADER_DATE = { Foreground = { Color = "#ffccac" }, Text = "󱪺" }
local HEADER_TIME = { Foreground = { Color = "#bcbabe" }, Text = "" }
local HEADER_BATTERY = { Foreground = { Color = "#dfe166" }, Text = "" }

function AddElement(elems, header, str)
	table.insert(elems, { Foreground = header.Foreground })
	table.insert(elems, { Background = DEFAULT_BG })
	table.insert(elems, { Text = header.Text .. SPACE_1 })

	table.insert(elems, { Foreground = DEFAULT_FG })
	table.insert(elems, { Background = DEFAULT_BG })
	table.insert(elems, { Text = str .. SPACE_3 })
end

local function GetHostAndCwd(elems, pane)
	local url = pane:get_current_working_dir()

	if not url then
		return
	end

	local cwd_url = url.file_path
	local slash = cwd_url:find("/")

	if not slash then
		return
	end

	-- local host = cwd_url:sub(1, slash - 1)
	-- local dot = host:find '[.]'

	-- AddElement(elems, HEADER_HOST, dot and host:sub(1, dot - 1) or host)
	AddElement(elems, HEADER_CWD, cwd_url:sub(slash))
end

local function GetDate(elems)
	AddElement(elems, HEADER_DATE, wezterm.strftime("%a %b %-d"))
end

local function GetTime(elems)
	AddElement(elems, HEADER_TIME, wezterm.strftime("%H:%M"))
end

local function GetBattery(elems, window)
	if not window:get_dimensions().is_full_screen then
		return
	end

	for _, b in ipairs(wezterm.battery_info()) do
		AddElement(elems, HEADER_BATTERY, string.format("%.0f%%", b.state_of_charge * 100))
	end
end

local function RightUpdate(window, pane)
	local elems = {}

	GetHostAndCwd(elems, pane)
	GetDate(elems)
	GetBattery(elems, window)
	GetTime(elems)

	window:set_right_status(wezterm.format(elems))
end

wezterm.on("update-status", function(window, pane)
	RightUpdate(window, pane)
end)

-- change cursor color https://github.com/mozumasu/dotfiles/blob/main/.config/wezterm/statusbar.lua

local WORKSPACE_COLORS = {
	default = "#ffffff",
	copy_mode = "#ffd700",
	-- setting_mode = "#39FF14",
}

-- 前回の色を記録（不要な更新を避けるため）
local last_color = nil
-- ステータスバー更新（ワークスペース名表示 & カーソル色変更）
wezterm.on("update-status", function(window, pane)
	local key_table = window:active_key_table()
	local color = WORKSPACE_COLORS[key_table] or WORKSPACE_COLORS.default

	-- カーソル色変更（OSCエスケープシーケンスを使用）
	if last_color ~= color then
		last_color = color
		-- OSC 12 でカーソル色を変更: \x1b]12;<color>\x1b\\
		pane:inject_output("\x1b]12;" .. color .. "\x1b\\")
	end
end)
