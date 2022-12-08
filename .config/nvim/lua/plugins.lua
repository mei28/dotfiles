local status, packer = pcall(require, "packer")
if not status then
  print("Packer is not installed")
  return
end
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

packer.startup(function()
  -- opt オプションを付けると遅延読み込みになります。 この場合は opt だけで読み込む契機を指定していないため、
  -- `packadd` コマンドを叩かない限り読み込まれることはありません。
  use 'wbthomason/packer.nvim'

  -- color scheme
  use 'cocopon/iceberg.vim'
  use 'arcticicestudio/nord-vim'
  use 'sainnhe/edge'
  use 'EdenEast/nightfox.nvim'
  use 'folke/tokyonight.nvim'
  use 'raphamorim/lucario'
  use 'w0ng/vim-hybrid'
  use 'nanotech/jellybeans.vim'
  use 'matsuuu/pinkmare'
  use '4513ECHO/vim-colors-hatsunemiku'
  use 'catppuccin/nvim'
  use 'rebelot/kanagawa.nvim'


  -- status line
  use 'nvim-lualine/lualine.nvim'

  -- indent
  use "lukas-reineke/indent-blankline.nvim"

  -- auto pair and tag close
  use { 'windwp/nvim-autopairs', event = 'InsertEnter' }
  use { 'windwp/nvim-ts-autotag', event = 'InsertEnter' }

  -- surround
  use "kylechui/nvim-surround"
  -- use"tpope/vim-surround"

  -- git
  use 'dinhhuy258/git.nvim'
  use 'lewis6991/gitsigns.nvim'
  use 'airblade/vim-gitgutter'


  use 'numToStr/Comment.nvim'

  use 'luochen1990/rainbow'

  -- dot repeat
  use 'tpope/vim-repeat'

  -- linter, formatter
  use 'jose-elias-alvarez/null-ls.nvim'

  -- markdown
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" }
  })

  -- utility
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  -- fuzzy finder
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- File icons
  use 'kyazdani42/nvim-web-devicons'

  -- treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use({ "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter" })

  -- bufferline
  use 'akinsho/nvim-bufferline.lua'

  -- show color
  use 'norcalli/nvim-colorizer.lua'

  -- csv
  use 'Decodetalkers/csv-tools.lua'

  -- comment
  use 'folke/todo-comments.nvim'

  -- views
  use 'petertriho/nvim-scrollbar'
  use 'kevinhwang91/nvim-hlslens'

  -- keep lastest cursor position
  use 'ethanholz/nvim-lastplace'

  -- sidebar-nvim
  use 'sidebar-nvim/sidebar.nvim'

  -- hop
  use 'phaazon/hop.nvim'

  -- mkdir
  use 'jghauser/mkdir.nvim'

  ---
  use "tversteeg/registers.nvim"

  --- code action list
  use "aznhe21/actions-preview.nvim"

  --- lsp
  use "neovim/nvim-lspconfig"
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  --- cmp
  use 'onsails/lspkind-nvim' -- vscode-like pictograms
  use 'L3MON4D3/LuaSnip'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'yutkat/cmp-mocword'
  use 'ray-x/cmp-treesitter'

  --- docstring
  use 'pixelneo/vim-python-docstring'

  --- noice
  use 'folke/noice.nvim'
  use 'MunifTanjim/nui.nvim'

  --- ddc
  -- use "Shougo/ddc.vim"
  -- use "vim-denops/denops.vim"
  -- use "Shougo/ddc-nvim-lsp"
  -- use "Shougo/ddc-around"
  -- use "LumaKernel/ddc-file"
  -- use "matsui54/ddc-buffer"
  -- use "Shougo/ddc-sorter_rank"
  -- use "tani/ddc-fuzzy"
  -- use "Shougo/ddc-matcher_head"
  -- use "Shougo/ddc-matcher_length"
  -- use "matsui54/denops-signature_help"
  -- use "matsui54/denops-popup-preview.vim"
  -- use "Shougo/pum.vim"

end)
