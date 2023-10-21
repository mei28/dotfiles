local spec = {
  -- fold
  {
    'anuvyklack/pretty-fold.nvim',
    config = function()
      require 'pretty-fold'.setup()
    end,
    event = { 'ModeChanged' },
  },

}
return spec
