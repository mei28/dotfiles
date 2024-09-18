local spec = {
  {
    "ptdewey/yankbank-nvim",
    event = { 'TextYankPost' },
    dependencies = "kkharji/sqlite.lua",
    config = function()
      require('yankbank').setup({
        persist_type = "sqlite",
      })
    end,
    keys = {
      { '<leader>y', '<CMD>YankBank<CR>', 'n' },
    },
  }
}

return spec
