local spec = {
  -- preview to jump
  {
    'nacro90/numb.nvim',
    config = function() require 'numb'.setup() end,
    event = {
      "ModeChanged",
    }
  },
}

return spec
