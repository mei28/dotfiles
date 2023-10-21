local spec = {
  {
    'utilyre/barbecue.nvim',
    event = { 'BufNewFile', 'BufRead' },
    version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
    },
  },
}
return spec
