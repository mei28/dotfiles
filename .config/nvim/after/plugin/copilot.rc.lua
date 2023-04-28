local status, copilot = pcall(require, 'copilot')
if not status then return end
local status, cop_cmp = pcall(require, 'copilot_cmp')
if not status then return end

copilot.setup({ suggestion = { enabled = false },
  panel = { enabled = false }, })
cop_cmp.setup({})
