local spec = {
  {
    'tani/dmacro.nvim',
    event = { 'CursorHold', 'CursorMoved' },
    config = function()
      require('dmacro').setup({
        dmacro_key = '<C-y>' --  you need to set the dmacro_key
      })
    end,
  }
}

return spec
