-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require'packer'.startup(
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

  use'nvim-lualine/lualine.nvim'

  use'Yggdroot/indentLine'

  use 'windwp/nvim-autopairs'

  use'tpope/vim-surround'

  use'dinhhuy258/git.nvim' 
  use'airblade/vim-gitgutter'

  use'easymotion/vim-easymotion'

  use'tpope/vim-commentary'

  use'luochen1990/rainbow'

  use'tpope/vim-repeat'

  use"jose-elias-alvarez/buftabline.nvim"

  use'SirVer/ultisnips'

  use'dense-analysis/ale'

  use{'previm/previm',
    opt=true,
    ft={'markdown'},
    setup = function()
      vim.g.previm_open_cmd='open -a Google Chrome'
    end
  }

  use{
    'alvan/vim-closetag',
    ft={'html'},
    setup = function()
      vim.g.closetag_filenames='*.html,*.xthml'
    end
  }

  use'nvim-lua/plenary.nvim'
  use'nvim-telescope/telescope.nvim'
  use'nvim-telescope/telescope-file-browser.nvim'

  use'kyazdani42/nvim-web-devicons' -- File icons

  use{
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  use'akinsho/nvim-bufferline.lua'

  use'norcalli/nvim-colorizer.lua'

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

