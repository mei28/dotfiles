local wezterm = require("wezterm")
local utils = require("utils")

local M = {}
M.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.5,
}

M.window_padding = {
	left = 0,
	right = 20,
	top = 10,
	bottom = 0,
}
M.background = {
	{
		source = {
			File = utils:randomBackgroundImage(),
		},
		width = "100%",
		hsb = { brightness = 0.05, hue = 1.0, saturation = 1.0 },
		vertical_align = "Middle",
		horizontal_align = "Center",
	},
}

-- 透過度の段階設定（nil = 背景画像表示）
-- 値を追加/変更することで段階数を調整可能
local opacity_levels = { 0.3, 0.8, 1.0 }

M.toggle_opacity = function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local current = overrides.window_background_opacity

	-- 現在の透過度のインデックスを探す
	local current_index = #opacity_levels -- デフォルトは最後（nil）
	for i, level in ipairs(opacity_levels) do
		if level == current then
			current_index = i
			break
		end
	end

	-- 次の段階へ（ローテーション）
	local next_index = (current_index % #opacity_levels) + 1
	local next_opacity = opacity_levels[next_index]

	if next_opacity then
		overrides.window_background_opacity = next_opacity
		overrides.text_background_opacity = next_opacity
		overrides.background = {}
	else
		overrides.window_background_opacity = nil
		overrides.text_background_opacity = nil
		overrides.background = M.background
	end
	window:set_config_overrides(overrides)
end

-- https://zenn.dev/mozumasu/articles/mozumasu-wezterm-customization
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"

	if tab.is_active then
		background = "#ae8b2d"
		foreground = "#FFFFFF"
	end

	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

return M
