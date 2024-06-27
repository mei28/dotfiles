local spec = {
  {
    "svban/YankAssassin.nvim",
    event = { "CursorHold", "CursorMoved" },
    config = function()
      require("YankAssassin").setup {
        auto = true, -- if auto is true, autocmds are used. Whenever y is used anywhere, the cursor doesn't move to start
      }
    end,
  }

}

return spec
