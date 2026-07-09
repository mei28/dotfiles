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
      {
        "<leader>ca",
        function() require("actions-preview").code_actions() end,
        mode = { "n", "v" },
        desc = "LSP: code action (preview)",
      },
    }
  }
}

return spec
