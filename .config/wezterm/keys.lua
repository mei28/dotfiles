local status, wezterm = pcall(require, "wezterm")
if not status then
	return
end
require("status")

wezterm.on("toggle-opacity", require("window").toggle_opacity)

local act = wezterm.action
local M = {}
local keys = {
	{
		key = "\\",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "b",
		mods = "LEADER",
		action = act.RotatePanes("CounterClockwise"),
	},
	{ key = "n", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	-- activate pane selection mode with numeric labels
	{
		key = "0",
		mods = "LEADER",
		action = act.PaneSelect({}),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		key = "9",
		mods = "LEADER",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{ key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
	{ key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },
	-- resize
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	-- toggle opacity
	{ key = "u", mods = "CTRL", action = wezterm.action.EmitEvent("toggle-opacity") },
	-- Shift + Enter to send a newline
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },
	-- Copy previous command (prompt + input + output) to clipboard
	-- ref: https://www.docswell.com/s/mozumasu/5DWPG4-dotfiles-dragon#p16
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(act.ActivateCopyMode, pane)
			window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)
			window:perform_action(act.CopyMode("MoveToStartOfLine"), pane)
			window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
			window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)
			-- Exclude current prompt line
			window:perform_action(act.CopyMode("MoveUp"), pane)
			window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)
			window:perform_action(
				act.Multiple({
					{ CopyTo = "ClipboardAndPrimarySelection" },
					{ Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
				}),
				pane
			)
		end),
	},
}

local key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
	},
}

M.keys = keys
M.key_tables = key_tables
return M
