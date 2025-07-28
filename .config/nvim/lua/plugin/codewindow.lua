local spec = {
  {
    'gorbit99/codewindow.nvim',
    config = function()
      local codewindow = require('codewindow')
      codewindow.setup()
      codewindow.apply_default_keybinds()
    end,
    keys = {
      {
        '<leader>mm', function() require('codewindow').toggle_minimap() end,
      }
    }
  }
}

return spec
