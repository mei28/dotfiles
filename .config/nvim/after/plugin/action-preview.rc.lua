local status, action = pcall(require, 'actions-preview')

if not status then return end

vim.keymap.set({ "v", "n" }, "ga", require("actions-preview").code_actions)
action.setup({})
