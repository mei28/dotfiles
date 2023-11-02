local spec = {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local npairs = require('nvim-autopairs')
      npairs.setup {
        fast_wrap = { map = "<C-]>" }
      }
    end
  },
}

return spec
