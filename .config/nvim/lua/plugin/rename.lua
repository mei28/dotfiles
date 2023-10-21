local spec = {

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
    keys = {
      { '<Leader>rn', function() return ":IncRename " .. vim.fn.expand("<cword>") end }
    }
  },

}

return spec
