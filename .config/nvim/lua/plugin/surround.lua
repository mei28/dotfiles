local spec = {
  -- -- surround
  {
    'kylechui/nvim-surround',
    event = 'ModeChanged',
    config = function() require 'nvim-surround'.setup {} end,
  },
}

return spec
