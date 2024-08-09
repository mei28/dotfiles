local spec = {
  {
    "petertriho/nvim-scrollbar",
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      require('scrollbar').setup()
    end
  },

  {
    "tonymajestro/smart-scrolloff.nvim",
    event = { 'CursorMoved', 'CursorHold' },
    opts = {
      scrolloff_percentage = 0.2,
    },
  },

}

return spec
