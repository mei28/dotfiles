local wezterm = require("wezterm")

-- Claude Code tab state configuration
local claude_tab_states = {
	idle      = { icon = "󰏤", bg = "#7c3aed", dim_bg = "#3b1d70" },
	thinking  = { icon = "󰔟", bg = "#f59e0b", dim_bg = "#785006" },
	executing = { icon = "󰐊", bg = "#10b981", dim_bg = "#085c40" },
}

-- Url lowercases the host it parses from OSC 7, while hostname() keeps the case.
local local_host = wezterm.hostname():lower()

-- Label from the foreground process and the cwd, e.g. "herdr TIIS_Yang".
-- A cwd reported from another host (over ssh) reads "host:dir".
local function process_and_dir(pane)
	local parts = {}
	local process = pane.foreground_process_name:match("[^/]+$")
	if process then
		table.insert(parts, process)
	end
	local cwd = pane.current_working_dir
	if cwd then
		local dir = cwd.file_path:match("[^/]+$") or "/"
		if cwd.host and cwd.host ~= local_host then
			dir = cwd.host .. ":" .. dir
		end
		table.insert(parts, dir)
	end
	return table.concat(parts, " ")
end

-- The Claude title stays authoritative; a manual rename via tab:set_title() only
-- applies while Claude is not driving this tab.
local function resolve_title(tab)
	local claude_title = tab.active_pane.user_vars.claude_title or ""
	if claude_title ~= "" then
		return claude_title
	end
	if tab.tab_title ~= "" then
		return tab.tab_title
	end
	-- Claude Code clears the pane title with an empty OSC 0 on exit and the shell
	-- never sets one, so an empty title would leave the tab blank.
	if tab.active_pane.title ~= "" then
		return tab.active_pane.title
	end
	return process_and_dir(tab.active_pane)
end

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

	-- 1-based to match CMD+<n>.
	local number = (tab.tab_index + 1) .. " "
	local title = " " .. edge .. " " .. number .. prefix .. wezterm.truncate_right(resolve_title(tab), max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)
