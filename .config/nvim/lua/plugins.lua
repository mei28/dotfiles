
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
  use'FrenzyExists/aquarium-vim'
  use'folke/tokyonight.nvim'
  use'raphamorim/lucario'
  use'w0ng/vim-hybrid'
  use'nanotech/jellybeans.vim'
  -- vim.api.nvim_command[[colorscheme iceberg]]
  -- vim.api.nvim_command[[colorscheme nord]]
  -- vim.api.nvim_command[[colorscheme edge]]
  vim.api.nvim_command[[colorscheme tokyonight]]
  -- vim.api.nvim_command[[colorscheme lucario]]
  -- vim.api.nvim_command[[colorscheme hybrid]]
  -- vim.api.nvim_command[[colorscheme jellybeans]]

  use'nvim-lualine/lualine.nvim'

  use'Yggdroot/indentLine'

  use'jiangmiao/auto-pairs'

  use'tpope/vim-surround'
  
  use'airblade/vim-gitgutter'

  use'tpope/vim-fugitive'
  use{
    'preservim/nerdtree',
    setup = function()
      vim.api.nvim_set_keymap('', '<Leader>b', ':NERDTreeToggle<CR>', {noremap=true, silent=true})
    end
  }

  use{
    'easymotion/vim-easymotion',
    setup = function()
      vim.g.EasyMotion_keys="hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB"
    end
  }
  
  use'tpope/vim-commentary'
  
  use{
    'luochen1990/rainbow',
    setup = function()
      vim.g.rainbow_active=1
    end
  }

  use'tpope/vim-repeat'

  use'ap/vim-buftabline'

  use{
    'SirVer/ultisnips',
    setup = function()
      vim.g.UltiSnipsExpandTrigger="<C-g><C-g>"
      vim.g.UltiSnipsJumpForwardTrigger="<C-f>"
      vim.g.UltiSnipsJumpBackwardTrigger="<C-b>"
      vim.g.UltiSnipsEditSplit="vertical"
    end
  }

  use'dense-analysis/ale'

  use{
    'previm/previm',
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

  --- lsp
  use"neovim/nvim-lspconfig"
  use"williamboman/nvim-lsp-installer"

  use "Shougo/ddc.vim"
  use'vim-denops/denops.vim'
  use'Shougo/ddc-nvim-lsp'
  use'Shougo/ddc-around'
  use'LumaKernel/ddc-file'
  use'matsui54/ddc-buffer'
  use'Shougo/ddc-sorter_rank'
  use'tani/ddc-fuzzy'
  use'Shougo/ddc-matcher_head'
  use'Shougo/ddc-matcher_length'
  use'matsui54/denops-signature_help'
  use'matsui54/denops-popup-preview.vim'
  use'Shougo/pum.vim'

end)

