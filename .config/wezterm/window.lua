local wezterm = require 'wezterm'
local utils = require 'utils'

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
    width = '100%',
    hsb = { brightness = 0.05, hue = 1.0, saturation = 1.0, },
    vertical_align = 'Middle',
    horizontal_align = 'Center',
  }
}


M.toggle_opacity = function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.3
    overrides.text_background_opacity = 0.3
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
