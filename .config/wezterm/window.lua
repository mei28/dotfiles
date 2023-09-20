local wezterm = require 'wezterm'

local M = {}
M.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}

M.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
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

return M
