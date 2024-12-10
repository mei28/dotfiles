local spec = {
  {
    "Goose97/timber.nvim",
    version = '*',
    config = function()
      require("timber").setup({
      })
    end,
    keys = {
      { 'glj' }, { 'glk' }, { 'glb' }
    }
  }
}

return spec
