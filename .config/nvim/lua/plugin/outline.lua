local spec = {
  {
    'simrat39/symbols-outline.nvim',
    config = function()
      local status, outline = pcall(require, 'symbols-outline')
      if not status then return end
      outline.setup({
        position = 'right',
        auto_preview = true,
        auto_close = true,
        show_number = true,
        show_symbol_details = true,
      })
    end,
    keys = {
      { ';a', '<CMD>SymbolsOutline<CR>' },
    },

  }

}

return spec
