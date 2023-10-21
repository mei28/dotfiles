local spec = {
  -- terminal
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup { size = 30, direction = 'float' }
      vim.api.nvim_create_autocmd({ "TermEnter" }, {
        pattern = { "term://*toggleterm#*" },
        callback = function()
          vim.keymap.set("t", "<C-t>", "<cmd>exe v:count1 . 'ToggleTerm'<cr>")
        end
      })
    end,
    keys = {
      { "<C-t>", "<cmd>exe v:count1 . 'ToggleTerm'<cr>", { "i", "n" } }

    }
  },
}

return spec
