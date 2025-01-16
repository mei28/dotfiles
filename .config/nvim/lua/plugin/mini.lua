local spec = {
  {
    'echasnovski/mini.align',
    version = false,
    event   = { 'CursorMoved', 'ModeChanged' },
    config  = function()
      require('mini.align').setup({})
    end
  },
  {
    'echasnovski/mini.diff',
    version = false,
    event = { 'CursorMoved', "ModeChanged" },
    config = function()
      require('mini.diff').setup({
      })
    end,
    keys = { { 'gh' }, { 'gH' }, { '[H' }, { '[h' }, { ']H' }, { ']h' } }
  }
}

return spec
