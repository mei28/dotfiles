local spec = {
  {
    'mei28/toggleqf.nvim',
    config = function() require('toggleqf').setup() end,
    keys = { '<C-g><C-o>', '<C-g><C-o>' },
  },
}

return spec
