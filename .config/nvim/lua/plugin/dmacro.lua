local spec = {
  {
    'tani/dmacro.vim',
    event = { 'CursorHold', 'CursorMoved' },
    config = function()
      -- require('dmacro').setup({
      --   dmacro_key = '<C-2>' --  you need to set the dmacro_key
      -- })
      vim.keymap.set('n', '<C-2>', '<Plug>(dmacro_play_macro)')
    end,
  }
}

return spec
