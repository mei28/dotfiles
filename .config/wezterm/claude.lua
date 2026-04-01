local wezterm = require("wezterm")

-- Claude Code tab state configuration
-- Easily customize icons and colors for each Claude Code state
local claude_tab_states = {
	idle      = { icon = "󰏤", bg = "#7c3aed" }, -- pause: waiting for input
	thinking  = { icon = "󰔟", bg = "#f59e0b" }, -- hourglass: processing
	executing = { icon = "󰐊", bg = "#10b981" }, -- play: running tool
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local prefix = ""

	-- Claude Code state detection via user variable (set by hooks)
	local claude_state = tab.active_pane.user_vars.claude_state or ""
	local state = claude_tab_states[claude_state]

	if state then
		background = state.bg
		prefix = state.icon .. " "
	elseif tab.is_active then
		background = "#ae8b2d"
	end

	-- Use claude_title when set, otherwise fall back to pane title
	local claude_title = tab.active_pane.user_vars.claude_title or ""
	local tab_title = claude_title ~= "" and claude_title or tab.active_pane.title
	local title = "   " .. prefix .. wezterm.truncate_right(tab_title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)
