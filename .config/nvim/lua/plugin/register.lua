local spec = {
  ---register
  {
    'tversteeg/registers.nvim',
    config = function()
      require 'registers'.setup()
    end,
    cmd = { "Registers" },
    keys = {
      { "\"", mode = { "n", "v" } },
    },
  },
}

return spec
