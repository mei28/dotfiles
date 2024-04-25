-- copilot

local spec = {
  {
    'zbirenbaum/copilot.lua',
    event = { 'InsertEnter' },
    config = function()
      local status, copilot = pcall(require, 'copilot')
      if not status then return end
      -- local status, cop_cmp = pcall(require, 'copilot_cmp')
      -- if not status then return end

      copilot.setup({
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-c>",
            accept_word = "<C-w>",
            accept_line = "<C-l>",
          },
        },
        filetypes = { markdown = true }
      })
      -- cop_cmp.setup({})
    end,
    cmd = 'Copilot'
  },
  -- {
  --   'zbirenbaum/copilot-cmp',
  --   event = { 'InsertEnter' },
  --   dependencies = { 'copilot.lua' },
  -- },
}




return spec
