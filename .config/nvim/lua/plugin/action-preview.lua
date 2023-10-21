local spec = {
  --- code action list
  {
    'aznhe21/actions-preview.nvim',
    config = function()
      local status, action = pcall(require, 'actions-preview')
      if not status then return end
      action.setup({})
    end,
    keys = {
      { "ga", function() require("actions-preview").code_actions() end, { "v", "n" } }
    }
  }
}

return spec
