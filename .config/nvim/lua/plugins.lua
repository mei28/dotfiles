
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
  vim.api.nvim_command[[colorscheme iceberg]]

  use {
    'nvim-lualine/lualine.nvim',
--    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }
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

  ---use{
  ---  'SirVer/ultisnips',
  ---  setup = function()
  ---    vim.g.UltiSnipsExpandTrigger="<C-g><C-g>"
  ---    --  let g:UltiSnipsJumpForwardTrigger="<c-f>"
  ---    --  let g:UltiSnipsJumpBackwardTrigger="<c-b>"
  ---    -- If you want :UltiSnipsEdit to split your window.
  ---    vim.g.UltiSnipsEditSplit="vertical"
  ---  end
  ---}

  use{
    'dense-analysis/ale',
    setup = function()
      vim.g.ale_sign_error='E'
      vim.g.ale_sign_warning='W'
      vim.g.ale_sign_column_always=1
      -- vim.g.ale_statusline_format=['⨉ %d', '⚠ %d', '⬥ ok']
      vim.g.ale_echo_msg_error_str='E'
      vim.g.ale_echo_msg_warning_str='W'
      vim.g.ale_echo_msg_format='[%linter%] %s [%severity%]'
      vim.g.ale_fix_on_save=1
    end
  }

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
  
end)

