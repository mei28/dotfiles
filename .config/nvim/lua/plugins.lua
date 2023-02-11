local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local status, lazy = pcall(require, "lazy")
if not status then
  print("lazy is not installed")
  return
end

lazy.setup({
  -- opt オプションを付けると遅延読み込みになります。 この場合は opt だけで読み込む契機を指定していないため、
  -- `packadd` コマンドを叩かない限り読み込まれることはありません。
  'wbthomason/packer.nvim',

  -- color scheme
  { 'cocopon/iceberg.vim', lazy = true },
  { 'arcticicestudio/nord-vim', lazy = true },
  { 'sainnhe/edge', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'folke/tokyonight.nvim', lazy = true },
  { 'w0ng/vim-hybrid', lazy = true },
  { 'nanotech/jellybeans.vim', lazy = true },
  { 'matsuuu/pinkmare', lazy = true },
  { '4513ECHO/vim-colors-hatsunemiku', lazy = true },
  { 'catppuccin/nvim', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'laniusone/kyotonight.vim', lazy = true },
  { 'sainnhe/everforest', lazy = true },
  { 'ayu-theme/ayu-vim', lazy = true },
  { 'catppuccin/catppuccin', lazy = true },
  { 'is-hoku/sakura', lazy = true },
  { 'navarasu/onedark.nvim', lazy = true },
  { 'morhetz/gruvbox', lazy = true },

  -- status line
  'nvim-lualine/lualine.nvim',

  -- indent
  "lukas-reineke/indent-blankline.nvim",

  -- auto pair and tag close
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',


  -- surround
  "kylechui/nvim-surround",
  -- "tpope/vim-surround"

  -- git
  'dinhhuy258/git.nvim',
  'lewis6991/gitsigns.nvim',
  'airblade/vim-gitgutter',
  'akinsho/git-conflict.nvim',


  'numToStr/Comment.nvim',

  'luochen1990/rainbow',

  -- dot repeat
  'tpope/vim-repeat',

  -- linter, formatter
  'jose-elias-alvarez/null-ls.nvim',

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" }
  },

  -- utility
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',

  -- fuzzy finder
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-file-browser.nvim',

  -- File icons
  'kyazdani42/nvim-web-devicons',

  -- treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { "yioneko/nvim-yati", dependencies = "nvim-treesitter/nvim-treesitter" },

  -- bufferline
  'akinsho/nvim-bufferline.lua',

  -- show color
  'norcalli/nvim-colorizer.lua',

  -- csv
  'Decodetalkers/csv-tools.lua',

  -- comment
  'folke/todo-comments.nvim',

  -- views
  'petertriho/nvim-scrollbar',
  'kevinhwang91/nvim-hlslens',

  -- keep lastest cursor position
  'ethanholz/nvim-lastplace',

  -- sidebar-nvim
  'sidebar-nvim/sidebar.nvim',

  -- hop
  'phaazon/hop.nvim',

  -- mkdir
  'jghauser/mkdir.nvim',

  ---
  "tversteeg/registers.nvim",

  --- code action list
  "aznhe21/actions-preview.nvim",

  --- lsp
  "neovim/nvim-lspconfig",
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',

  --- cmp
  'onsails/lspkind-nvim', -- vscode-like pictograms
  'L3MON4D3/LuaSnip',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'yutkat/cmp-mocword',
  'ray-x/cmp-treesitter',

  --- docstring
  -- 'pixelneo/vim-python-docstring',

  --- noice
  'folke/noice.nvim',
  'MunifTanjim/nui.nvim',
  {'folke/trouble.nvim'}

  -- -- status line
  -- use "luukvbaal/statuscol.nvim"

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

})
