local spec = {

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
    cmd = {
      "IncRename"
    }
  },

}

return spec
