local spec = {
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<Leader>u", "<CMD>lua require('undotree').toggle()<CR>" },
    },
  },
}

return spec
