-- copilot

local spec = {
  {
    'zbirenbaum/copilot.lua',
    event = { 'InsertEnter' },
    config = function()
      local status, copilot = pcall(require, 'copilot')
      if not status then return end
      local status, cop_cmp = pcall(require, 'copilot_cmp')
      if not status then return end

      copilot.setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        fix_pairs = true,
      })
      cop_cmp.setup({})
    end,
    cmd = 'Copilot'
  },
  { 'zbirenbaum/copilot-cmp', event = { 'InsertEnter' }, dependencies = { 'copilot.lua' }, },
}

return spec
