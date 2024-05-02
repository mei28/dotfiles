local spec = {
  ---register
  {
    'tversteeg/registers.nvim',
    config = function()
      local registers = require('registers')
      registers.setup(
        {
          show = "*+\"-/_=#%.0123456789abcdefghilmnopqrstuvwxyz:",
        }
      )
    end,
    cmd = { "Registers" },
    keys = {
      { "\"", mode = { "n", "v" } },
    },
  },
}

return spec
