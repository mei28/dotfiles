local status, wezterm = pcall(require, 'wezterm')
if not status then return end
local utils = require 'utils'
local keys = require 'keys'
local window = require 'window'
require 'status'

local act = wezterm.action

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
local skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
}


--- config ----
local config = {}

config.default_prog = { '/Users/mei/.nix-profile/bin/bash', '-l' }
-- font
config.font = wezterm.font_with_fallback(utils:switchFonts())
config.font_size = 16
-- color scheme
config.color_scheme = utils:randomColorScheme()
-- turn off beep
config.audible_bell = 'Disabled'
config.hide_tab_bar_if_only_one_tab = false
-- not to resize window
config.adjust_window_size_when_changing_font_size = false
-- ime ime for mac
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"
-- like tmux key bind
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }
-- tmux like key bind
config.keys = keys.keys
config.key_tables = keys.key_tables
-- hyperlink
config.hyperlink_rules = hyperlink_rules
-- window padding
config.window_padding = window.window_padding
-- skip confirm when clone
config.skip_close_confirmation_for_processes_named = skip_close_confirmation_for_processes_named
-- inactive_pane_hsb
config.inactive_pane_hsb = window.inactive_pane_hsb
config.check_for_updates = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW"

-- background
config.background = window.background

config.quote_dropped_files = "Posix"

return config
