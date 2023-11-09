local spec = {
  {
    "petertriho/nvim-scrollbar",
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      require('scrollbar').setup()
    end
  },
}

return spec
