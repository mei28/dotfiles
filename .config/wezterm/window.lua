local wezterm = require 'wezterm'
local utils = require 'utils'

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

return M
