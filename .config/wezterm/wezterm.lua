local status, wezterm = pcall(require, 'wezterm')
if not status then return end
local utils = require 'utils'


local act = wezterm.action


local keys = {
  {
    key = '\\',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane { confirm = false } },
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  {
    key = 'b',
    mods = 'LEADER',
    action = act.RotatePanes 'CounterClockwise',
  },
  { key = 'n', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },
  -- activate pane selection mode with numeric labels
  {
    key = '0',
    mods = 'LEADER',
    action = act.PaneSelect {
    },
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    key = '9',
    mods = 'LEADER',
    action = act.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(1) },
  -- resize
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
  -- toggle opacity
  { key = 'u', mods = 'CTRL', action = wezterm.action.EmitEvent 'toggle-opacity' },
}

local key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { "Left", 1 } },
    { key = 'j', action = act.AdjustPaneSize { "Down", 1 } },
    { key = 'k', action = act.AdjustPaneSize { "Up", 1 } },
    { key = 'l', action = act.AdjustPaneSize { "Right", 1 } },
    { key = 'LeftArrow', action = act.AdjustPaneSize { "Left", 1 } },
    { key = 'DownArrow', action = act.AdjustPaneSize { "Down", 1 } },
    { key = 'UpArrow', action = act.AdjustPaneSize { "Up", 1 } },
    { key = 'RightArrow', action = act.AdjustPaneSize { "Right", 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'q', action = 'PopKeyTable' },
  },
}

local hyperlink_rules = {
  -- Linkify things that look like URLs and the host has a TLD name.
  -- Compiled-in default. Used if you don't specify any hyperlink_rules.
  {
    regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
    format = '$0',
  },

  -- linkify email addresses
  -- Compiled-in default. Used if you don't specify any hyperlink_rules.
  {
    regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
    format = 'mailto:$0',
  },

  -- file:// URI
  -- Compiled-in default. Used if you don't specify any hyperlink_rules.
  {
    regex = [[\bfile://\S*\b]],
    format = '$0',
  },

  -- Linkify things that look like URLs with numeric addresses as hosts.
  -- E.g. http://127.0.0.1:8000 for a local development server,
  -- or http://192.168.1.1 for the web interface of many routers.
  {
    regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
    format = '$0',
  },

  -- Make task numbers clickable
  -- The first matched regex group is captured in $1.
  {
    regex = [[\b[tT](\d+)\b]],
    format = 'https://example.com/tasks/?t=$1',
  },

  -- Make username/project paths clickable. This implies paths like the following are for GitHub.
  -- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
  -- As long as a full URL hyperlink regex exists above this it should not match a full URL to
  -- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
  {
    regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    format = 'https://www.github.com/$1/$3',
  },
}
local window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
local skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
}

local inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.3
    overrides.text_background_opacity = 0.3
  else
    overrides.window_background_opacity = nil
    overrides.text_background_opacity = nil
  end
  window:set_config_overrides(overrides)
end)

--- config ----
local config = {}

config.default_prog = { '/bin/bash', '-l' }
-- font
config.font = wezterm.font_with_fallback(utils:switchFonts())
config.font_size = 13
-- color scheme
config.color_scheme = utils:randomColorScheme()
-- turn off beep
config.audible_bell = 'Disabled'
config.hide_tab_bar_if_only_one_tab = true
-- not to resize window
config.adjust_window_size_when_changing_font_size = false
-- ime ime for mac
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"
-- like tmux key bind
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }
-- tmux like key bind
config.keys = keys
config.key_tables = key_tables
-- hyperlink
config.hyperlink_rules = hyperlink_rules
-- window padding
config.window_padding = window_padding
-- skip confirm when clone
config.skip_close_confirmation_for_processes_named = skip_close_confirmation_for_processes_named
-- inactive_pane_hsb
config.inactive_pane_hsb = inactive_pane_hsb
config.check_for_updates = false
-- hide title bar
config.window_decorations = "RESIZE|TITLE"

return config
