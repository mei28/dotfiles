-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require'packer'.startup(function()
  -- opt オプションを付けると遅延読み込みになります。
  -- この場合は opt だけで読み込む契機を指定していないため、
  -- `packadd` コマンドを叩かない限り読み込まれることはありません。
  use'wbthomason/packer.nvim'

  -- color scheme
  use'cocopon/iceberg.vim'

  use'Yggdroot/indentLine'

  use'jiangmiao/auto-pairs'

  use'tpope/vim-surround'
end)
