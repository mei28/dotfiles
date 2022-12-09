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
    key = 'H',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'J',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Down', 5 },
  },
  { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 5 } },
  {
    key = 'L',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Right', 5 },
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



return {
  -- init shell
  default_prog = { '/bin/bash', '-l' },
  -- font
  font = wezterm.font_with_fallback(utils:switchFonts()),
  font_size = 13,
  -- color scheme
  color_scheme = utils:randomColorScheme(),
  -- turn off beep
  audible_bell = 'Disabled',
  hide_tab_bar_if_only_one_tab = true,
  -- not to resize window
  adjust_window_size_when_changing_font_size = false,
  -- ime
  use_ime = true,
  -- like tmux key bind
  leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 },
  -- tmux like key bind
  keys = keys,
  -- hyperlink
  hyperlink_rules = hyperlink_rules,
  -- window padding
  window_padding = window_padding,
  -- skip confirm when clone
  skip_close_confirmation_for_processes_named = skip_close_confirmation_for_processes_named,
  -- inactive_pane_hsb
  inactive_pane_hsb = inactive_pane_hsb,
  check_for_updates = false,

}
