local spec = {

  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup()
    end,
    cmd = { 'Oil' },
    keys = {
      { '-', '<CMD>Oil<CR>', 'n' }
    }
  }
}

return spec
