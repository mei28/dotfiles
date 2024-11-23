local spec = {
  {
    "saecki/live-rename.nvim",
    keys = {
      { "<leader>lr", function()
        require 'live-rename'.rename({ insert = true })
      end, 'n', { description = 'Rename the symbol under the cursor' } },

    }
  }
}

return spec
