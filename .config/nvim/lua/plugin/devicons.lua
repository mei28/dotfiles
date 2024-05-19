local spec = {
  -- File icons
  {
    'nvim-tree/nvim-web-devicons',
    event = { 'BufNewFile', 'BufRead' },
  },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    event = { "BufNewFile", "BufRead" },
    config = function()
      require('tiny-devicons-auto-colors').setup()
    end
  }
}


return spec
