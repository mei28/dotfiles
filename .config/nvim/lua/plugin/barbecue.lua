local spec = {
  {
    'utilyre/barbecue.nvim',
    event = { 'BufNewFile', 'BufRead' },
    dependencies = {
      'SmiteshP/nvim-navic',
    },
  },
}
return spec
