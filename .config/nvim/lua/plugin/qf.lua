local spec = {
  {
    'yorickpeterse/nvim-pqf',
    ft = 'qf',
    config = function()
      require('pqf').setup()
    end
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = function()
      require('bqf').setup()
    end
  },
}

return spec
