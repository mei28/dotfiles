local spec = {
  {
    'hrsh7th/nvim-swm',
    config = function()
      require('swm')
    end,
    keys = {
      { '<C-w>h', function() require('swm').h() end, 'n' },
      { '<C-w>j', function() require('swm').j() end, 'n' },
      { '<C-w>k', function() require('swm').k() end, 'n' },
      { '<C-w>l', function() require('swm').l() end, 'n' },
    }
  }
}

return spec
