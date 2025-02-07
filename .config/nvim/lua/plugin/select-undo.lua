local spec = {
  {
    "sunnytamang/select-undo.nvim",
    config = function()
      require("select-undo").setup({
        persistent_undo = true, -- Enables persistent undo history
        mapping = true,         -- Enables default keybindings
        line_mapping = "gu",    -- Undo for entire lines
        partial_mapping = "gcu" -- Undo for selected characters
      })
    end,
    keys = { { 'gcu' }, { "gu" } }
  }
}

return spec
