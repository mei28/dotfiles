local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local status, lazy = pcall(require, 'lazy')
if not status then
  print('lazy is not installed')
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
  { 'bluz71/vim-nightfly-colors',      lazy = true },
  { "typicode/bg.nvim",                lazy = false },


  -- status line
  'nvim-lualine/lualine.nvim',

  -- indent
  { "lukas-reineke/indent-blankline.nvim", main = "ibl",                                      opts = {} },
  'atusy/tsnode-marker.nvim',

  -- auto pair and tag close
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    config = function()
      require 'nvim-ts-autotag'.setup()
    end
  },


  -- -- surround
  {
    'kylechui/nvim-surround',
    config = function() require 'nvim-surround'.setup {} end
  },
  --
  -- -- git
  'dinhhuy258/git.nvim',
  { 'lewis6991/gitsigns.nvim',             config = function() require 'gitsigns'.setup() end },
  'airblade/vim-gitgutter',
  { 'akinsho/git-conflict.nvim',  version = '*',                          config = true },
  'sindrets/diffview.nvim',
  'rhysd/git-messenger.vim',

  -- comment
  'numToStr/Comment.nvim',

  -- dot repeat
  'tpope/vim-repeat',

  -- linter, formatter
  -- 'jose-elias-alvarez/null-ls.nvim',

  -- markdown
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
    ft = { 'markdown', 'text' }
  },
  { 'toppair/peek.nvim',          build = 'deno task --quiet build:fast', ft = { 'markdown', 'text' } },
  -- table markdonw
  { 'dhruvasagar/vim-table-mode', ft = { 'markdown', 'text' } },
  { 'mattn/vim-maketable',        ft = { 'markdown', 'text' } },
  {
    'richardbizik/nvim-toc',
    ft = { 'markdown', 'text' },
    config = function()
      require('nvim-toc').setup()
    end
  },


  -- utility
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',
  "MunifTanjim/nui.nvim",

  -- fuzzy finder
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-file-browser.nvim',
  'nvim-telescope/telescope-ui-select.nvim',

  -- File icons
  'kyazdani42/nvim-web-devicons',

  -- treesitter
  { 'nvim-treesitter/nvim-treesitter', build = { ':TSInstall! vim', ':TSUpdate' } },
  { 'yioneko/nvim-yati',               dependencies = 'nvim-treesitter/nvim-treesitter' },

  -- bufferline
  'akinsho/nvim-bufferline.lua',

  -- color
  'norcalli/nvim-colorizer.lua',
  'uga-rosa/ccc.nvim',
  'RRethy/vim-illuminate',
  'fei6409/log-highlight.nvim',

  -- csv
  { 'Decodetalkers/csv-tools.lua', ft = 'csv' },

  -- comment
  { 'folke/todo-comments.nvim',    config = function() require 'todo-comments'.setup() end },

  -- views
  {
    'lewis6991/satellite.nvim',
    config = function()
      require('satellite').setup()
    end
  },
  'kevinhwang91/nvim-hlslens',

  -- keep lastest cursor position
  'ethanholz/nvim-lastplace',

  -- sidebar-nvim
  'sidebar-nvim/sidebar.nvim',

  -- hop
  -- 'rlane/pounce.nvim',
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
      },
      {
        "s",
        mode = { "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
    },
  },

  -- mkdir
  'jghauser/mkdir.nvim',

  ---register
  { 'tversteeg/registers.nvim', config = function() require 'registers'.setup() end },

  --- code action list
  'aznhe21/actions-preview.nvim',

  --- lsp
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  "neovim/nvim-lspconfig",

  -- rename
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
      vim.keymap.set("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true })
    end,
  },

  --- cmp
  'onsails/lspkind-nvim', -- vscode-like pictograms
  {
    "L3MON4D3/LuaSnip",
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'yutkat/cmp-mocword',
  'hrsh7th/cmp-cmdline',
  'ray-x/cmp-treesitter',
  'saadparwaiz1/cmp_luasnip',
  'andersevenrud/cmp-tmux',
  'bydlw98/cmp-env',
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    config = function()
      require 'fidget'.setup({})
    end
  },


  --- dap
  'mfussenegger/nvim-dap',
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dapui").setup()
    end
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-treesitter' },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  },
  "nvim-telescope/telescope-dap.nvim",
  'simrat39/rust-tools.nvim',

  --- noice
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     -- "rcarriga/nvim-notify",
  --   }
  -- },
  'folke/trouble.nvim',

  --- obsidian
  { 'epwalsh/obsidian.nvim' },
  'BurntSushi/ripgrep',


  -- template
  'mattn/vim-sonictemplate',

  -- dial
  'monaqa/dial.nvim',

  -- chatgpt
  -- {
  --   'jackMort/ChatGPT.nvim',
  --   event = 'VeryLazy',
  --   dependencies = {
  --     'MunifTanjim/nui.nvim',
  --     'nvim-lua/plenary.nvim',
  --     'nvim-telescope/telescope.nvim'
  --   }
  -- },

  -- copilot
  { 'zbirenbaum/copilot.lua', event = 'InsertEnter',            cmd = 'Copilot' },
  { 'zbirenbaum/copilot-cmp', dependencies = { 'copilot.lua' }, },

  "dstein64/vim-startuptime",


  -- fold
  {
    'anuvyklack/pretty-fold.nvim',
    config = function()
      require 'pretty-fold'.setup()
    end
  },

  -- code out line
  'simrat39/symbols-outline.nvim',

  -- diff
  'AndrewRadev/linediff.vim',

  -- navigation
  'SmiteshP/nvim-navic',
  {
    'utilyre/barbecue.nvim',
    version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
    },
  },
  { 'Bekaboo/dropbar.nvim' },

  -- annotaion comment
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = '*'
  },

  -- start up
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
      require 'alpha'.setup(require 'alpha.themes.startify'.config)
    end
  },

  -- preview to jump
  { 'nacro90/numb.nvim',   config = function() require 'numb'.setup() end },

  -- remote-ssh
  -- {
  --   "amitds1997/remote-nvim.nvim",
  --   event = "VeryLazy",
  --   tag = "v0.0.1", -- It is recommended that you keep this pinned to a tag
  --   -- so that you do not pick up breaking changes
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --     -- This would be an optional dependency eventually
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   config = function() require('remote-nvim').setup() end,
  -- },

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup { size = 30, direction = 'float' }
      vim.api.nvim_create_autocmd({ "TermEnter" }, {
        pattern = { "term://*toggleterm#*" },
        callback = function()
          vim.keymap.set("t", "<C-t>", "<cmd>exe v:count1 . 'ToggleTerm'<cr>")
        end
      })
      vim.keymap.set({ "i", "n" }, "<C-t>", "<cmd>exe v:count1 . 'ToggleTerm'<cr>")
    end
  },

  -- f-string
  {
    "chrisgrieser/nvim-puppeteer",
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = false, -- plugin lazy-loads itself
  },

  -- url open
  {
    "sontungexpt/url-open",
    event = "VeryLazy",
    cmd = "URLOpenUnderCursor",
    config = function()
      local status_ok, url_open = pcall(require, "url-open")
      if not status_ok then
        return
      end
      url_open.setup({})
    end,
  },

  -- efm
  {
    'creativenull/efmls-configs-nvim',
    version = 'v1.x.x', -- version is optional, but recommended
    dependencies = { 'neovim/nvim-lspconfig' },
  }

})
