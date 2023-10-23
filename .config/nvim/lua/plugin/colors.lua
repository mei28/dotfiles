local spec = {
  {
    'norcalli/nvim-colorizer.lua',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.opt.termguicolors = true
      require 'colorizer'.setup()
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
    'RRethy/vim-illuminate',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.cmd("hi IlluminatedWordText cterm=underline ctermbg=8 gui=underline guibg=#104040")
      vim.cmd("hi IlluminatedWordRead cterm=underline ctermbg=8 gui=underline guibg=#104040")
      vim.cmd("hi IlluminatedWordWrite cterm=underline ctermbg=8 gui=underline guibg=#104040")
    end,
  },
  {
    'fei6409/log-highlight.nvim',
    ft = { 'log' },
    config = function()
      require('log-highlight').setup {}
    end,
  },
  {
    'mei28/luminate.nvim',
    event = { 'TextYankPost' },
    config = function()
      require 'luminate'.setup({})
    end
  }

}

return spec
