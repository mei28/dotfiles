local spec = {

  {
    'AckslD/nvim-anywise-reg.lua',
    event = { 'CursorMoved', 'CursorHold' },
    config = function()
      require("anywise_reg").setup(
        {
          paste_keys = {
            ['p'] = 'p',
            ['P'] = 'P'
          },
        }
      )
    end
  },

}

return spec
