local wezterm = require("wezterm")

-- Claude Code tab state configuration
local claude_tab_states = {
	idle      = { icon = "󰏤", bg = "#7c3aed", dim_bg = "#3b1d70" },
	thinking  = { icon = "󰔟", bg = "#f59e0b", dim_bg = "#785006" },
	executing = { icon = "󰐊", bg = "#10b981", dim_bg = "#085c40" },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local prefix = ""
	local edge = ""

	local claude_state = tab.active_pane.user_vars.claude_state or ""
	local state = claude_tab_states[claude_state]

	if state then
		prefix = state.icon .. " "
		if tab.is_active then
			background = state.bg
			edge = "▍"
		else
			background = state.dim_bg
			foreground = "#aaaaaa"
		end
	elseif tab.is_active then
		background = "#7a8a90"
		edge = "▍"
	else
		foreground = "#aaaaaa"
	end

	local claude_title = tab.active_pane.user_vars.claude_title or ""
	local tab_title = claude_title ~= "" and claude_title or tab.active_pane.title
	local title = " " .. edge .. " " .. prefix .. wezterm.truncate_right(tab_title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)
