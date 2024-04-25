local spec = {
  -- -- fold
  -- {
  --   'anuvyklack/pretty-fold.nvim',
  --   config = function()
  --     require 'pretty-fold'.setup()
  --   end,
  --   event = { 'ModeChanged' },
  -- },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = { 'ModeChanged' },
  }

}
return spec
