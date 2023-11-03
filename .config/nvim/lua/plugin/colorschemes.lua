return {
  -- color scheme
  { 'cocopon/iceberg.vim', },
  { 'arcticicestudio/nord-vim', },
  { 'sainnhe/edge', },
  { 'EdenEast/nightfox.nvim', },
  { 'folke/tokyonight.nvim', },
  { 'w0ng/vim-hybrid', },
  { 'nanotech/jellybeans.vim', },
  { 'matsuuu/pinkmare', },
  { '4513ECHO/vim-colors-hatsunemiku', },
  { 'catppuccin/nvim', },
  { 'rebelot/kanagawa.nvim', },
  { 'laniusone/kyotonight.vim', },
  { 'sainnhe/everforest', },
  { 'ayu-theme/ayu-vim', },
  { 'catppuccin/catppuccin', },
  { 'is-hoku/sakura', },
  { 'navarasu/onedark.nvim', },
  { 'morhetz/gruvbox', },
  { 'haxibami/urara.vim', },
  { 'bluz71/vim-nightfly-colors', },
  -- { "typicode/bg.nvim",              event = {'BufNewFile', 'BufRead'}  },
  {
    'xiyaowong/transparent.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() vim.cmd [[TransparentEnable]] end
  }
}
