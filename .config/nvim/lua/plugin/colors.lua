local spec = {
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.opt.termguicolors = true
      require('nvim-highlight-colors').setup {
        enable_tailwind = true,
        render = 'virtual',
        virtual_symbol_prefix = '[',
        virtual_symbol_suffix = ']',
        virtual_symbol_position = 'eol',
      }
    end

  },
  {
    'uga-rosa/ccc.nvim',
    config = function()
      -- Enable true color
      vim.opt.termguicolors = true
      local status, ccc = pcall(require, "ccc")
      if not status then return end
      local mapping = ccc.mapping

      ccc.setup({
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
      })
    end,
    cmd = { 'CccPick' },
  },
  {
    'fei6409/log-highlight.nvim',
    ft = { 'log' },
    config = function()
      require('log-highlight').setup {}
    end,
  },
}

return spec
