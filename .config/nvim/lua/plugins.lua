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
  -- color scheme
  { 'cocopon/iceberg.vim',             lazy = true },
  { 'arcticicestudio/nord-vim',        lazy = true },
  { 'sainnhe/edge',                    lazy = true },
  { 'EdenEast/nightfox.nvim',          lazy = true },
  { 'folke/tokyonight.nvim',           lazy = true },
  { 'w0ng/vim-hybrid',                 lazy = true },
  { 'nanotech/jellybeans.vim',         lazy = true },
  { 'matsuuu/pinkmare',                lazy = true },
  { '4513ECHO/vim-colors-hatsunemiku', lazy = true },
  { 'catppuccin/nvim',                 lazy = true },
  { 'rebelot/kanagawa.nvim',           lazy = true },
  { 'laniusone/kyotonight.vim',        lazy = true },
  { 'sainnhe/everforest',              lazy = true },
  { 'ayu-theme/ayu-vim',               lazy = true },
  { 'catppuccin/catppuccin',           lazy = true },
  { 'is-hoku/sakura',                  lazy = true },
  { 'navarasu/onedark.nvim',           lazy = true },
  { 'morhetz/gruvbox',                 lazy = true },
  { 'eihigh/vim-aomi-grayscale',       lazy = true },
  { 'haxibami/urara.vim',              lazy = true },
  { "bluz71/vim-nightfly-colors",      lazy = true },

  -- status line
  'nvim-lualine/lualine.nvim',

  -- indent
  "lukas-reineke/indent-blankline.nvim",
  "atusy/tsnode-marker.nvim",

  -- auto pair and tag close
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',


  -- surround
  "kylechui/nvim-surround",

  -- git
  'dinhhuy258/git.nvim',
  'lewis6991/gitsigns.nvim',
  'airblade/vim-gitgutter',
  { 'akinsho/git-conflict.nvim',       version = "*",                                   config = true },
  'sindrets/diffview.nvim',
  'rhysd/git-messenger.vim',

  -- comment
  'numToStr/Comment.nvim',

  -- rainbow
  'luochen1990/rainbow',

  -- dot repeat
  'tpope/vim-repeat',

  -- linter, formatter
  'jose-elias-alvarez/null-ls.nvim',

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" }
  },

  -- utility
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',

  -- fuzzy finder
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-file-browser.nvim',
  'nvim-telescope/telescope-ui-select.nvim',

  -- File icons
  'kyazdani42/nvim-web-devicons',

  -- treesitter
  { 'nvim-treesitter/nvim-treesitter', build = { ':TSInstall! vim', ':TSUpdate' } },
  { "yioneko/nvim-yati",               dependencies = "nvim-treesitter/nvim-treesitter" },

  -- bufferline
  'akinsho/nvim-bufferline.lua',

  -- color
  'norcalli/nvim-colorizer.lua',
  'uga-rosa/ccc.nvim',
  'RRethy/vim-illuminate',
  'fei6409/log-highlight.nvim',

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
  -- 'phaazon/hop.nvim',
  'ggandor/leap.nvim',

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
  'hrsh7th/cmp-cmdline',
  'ray-x/cmp-treesitter',
  'andersevenrud/cmp-tmux',
  'j-hui/fidget.nvim',


  --- noice
  'folke/noice.nvim',
  'MunifTanjim/nui.nvim',
  'folke/trouble.nvim',
  'rcarriga/nvim-notify',

  --- obsidian
  'epwalsh/obsidian.nvim',
  'BurntSushi/ripgrep',

  -- table markdonw
  'dhruvasagar/vim-table-mode',
  'mattn/vim-maketable',

  -- template
  'mattn/vim-sonictemplate',


  -- -- status line
  "luukvbaal/statuscol.nvim",

  -- dial
  'monaqa/dial.nvim',

  -- chatgpt
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },

  -- copilot
  { "zbirenbaum/copilot.lua", event = 'InsertEnter',            cmd = 'Copilot' },
  { "zbirenbaum/copilot-cmp", dependencies = { "copilot.lua" }, },

  -- fold
  'anuvyklack/pretty-fold.nvim',

  -- toggle term
  'uga-rosa/ugaterm.nvim',

  -- code out line
  'simrat39/symbols-outline.nvim',

  -- diff
  'AndrewRadev/linediff.vim',

})
