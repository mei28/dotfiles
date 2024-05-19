local spec = {
  {
    'hrsh7th/nvim-automa',
    event = { 'CursorHold', 'CursorMoved' },
    config = function()
      local automa = require 'automa'
      automa.setup({
        mapping = {
          ['.'] = {
            queries = {
              -- wide-range dot-repeat definition.
              automa.query_v1({ '!n(h,j,k,l)+' }),
            }
          },
        }
      })
    end
  }
}

return spec
