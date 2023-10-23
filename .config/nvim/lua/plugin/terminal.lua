local spec = {
  -- terminal
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup { size = 30, direction = 'float' }
      vim.api.nvim_create_autocmd({ "TermEnter" }, {
        pattern = { "term://*toggleterm#*" },
        callback = function()
          vim.keymap.set("t", "<C-t>", "<CMD>exe v:count1 . 'ToggleTerm'<CR>")
        end
      })
    end,
    keys = {
      { "<C-t>", "<CMD>exe v:count1 . 'ToggleTerm'<CR>", { "i", "n" } }

    }
  },
}

return spec
