local spec = {
  {
    'Bakudankun/BackAndForward.vim',
    keys = {
      { 'g<C-o>', '<cmd>Back<cr>',    desc = 'Go back (file unit)' },
      { 'g<C-i>', '<cmd>Forward<cr>', desc = 'Go forward (file unit)' },
    },
    config = function()
      -- jumpoptions の設定（推奨）
      vim.opt.jumpoptions:append('stack')
    end,
  }
}

return spec
