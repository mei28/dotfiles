local spec = {
  {
    'echasnovski/mini.align',
    version = false,
    event   = { 'CursorMoved', 'ModeChanged' },
    config  = function()
      require('mini.align').setup({})
    end
  },
}

return spec
