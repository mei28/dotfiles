local status, packer = pcall(require, "packer")
if not status then
  print("Packer is not installed")
  return
end
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

packer.startup(
  function()
  -- opt オプションを付けると遅延読み込みになります。 この場合は opt だけで読み込む契機を指定していないため、
  -- `packadd` コマンドを叩かない限り読み込まれることはありません。
  use'wbthomason/packer.nvim'

  -- color scheme
  use'cocopon/iceberg.vim'
  use'arcticicestudio/nord-vim'
  use'sainnhe/edge'
  use'EdenEast/nightfox.nvim'
  use'folke/tokyonight.nvim'
  use'raphamorim/lucario'
  use'w0ng/vim-hybrid'
  use'nanotech/jellybeans.vim'

  -- status line
  use'nvim-lualine/lualine.nvim'
  
  -- indent
  use"lukas-reineke/indent-blankline.nvim"

  -- auto pair and tag close
  use'windwp/nvim-autopairs'
  use'windwp/nvim-ts-autotag'

  -- surround
  use"kylechui/nvim-surround"
  -- use"tpope/vim-surround"

  -- git
  use'dinhhuy258/git.nvim'
  use'lewis6991/gitsigns.nvim'
  use'airblade/vim-gitgutter'

  -- easymotion
  use'easymotion/vim-easymotion'

  use'numToStr/Comment.nvim'

  use'luochen1990/rainbow'

  -- dot repeat
  use'tpope/vim-repeat'
  -- snipetts
  use'SirVer/ultisnips'

  -- linter, formatter
  use'dense-analysis/ale'

  -- markdown
  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

  -- utility
  use'nvim-lua/plenary.nvim'

  -- fuzzy finder
  use'nvim-telescope/telescope.nvim'
  use'nvim-telescope/telescope-file-browser.nvim'

  -- File icons
  use'kyazdani42/nvim-web-devicons'
  
  -- treesitter
  use{
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use({ "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter" })

  -- bufferline
  use'akinsho/nvim-bufferline.lua'

  -- show color
  use'norcalli/nvim-colorizer.lua'

  -- csv
  use'Decodetalkers/csv-tools.lua'

  -- comment
  use'folke/todo-comments.nvim'

  use'petertriho/nvim-scrollbar'
  use'kevinhwang91/nvim-hlslens'


  --- lsp
  use"neovim/nvim-lspconfig"
  use"williamboman/nvim-lsp-installer"

  use"Shougo/ddc.vim"
  use"vim-denops/denops.vim"
  use"Shougo/ddc-nvim-lsp"
  use"Shougo/ddc-around"
  use"LumaKernel/ddc-file"
  use"matsui54/ddc-buffer"
  use"Shougo/ddc-sorter_rank"
  use"tani/ddc-fuzzy"
  use"Shougo/ddc-matcher_head"
  use"Shougo/ddc-matcher_length"
  use"matsui54/denops-signature_help"
  use"matsui54/denops-popup-preview.vim"
  use"Shougo/pum.vim"


end)

