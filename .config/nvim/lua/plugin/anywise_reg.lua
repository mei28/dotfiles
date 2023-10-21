local spec = {

  {
    'AckslD/nvim-anywise-reg.lua',
    event = 'VeryLazy',
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
