local status, executor = pcall(require, 'executor')
if not status then return end

executor.setup({})
vim.api.nvim_set_keymap("n", "<Leader>er", ":ExecutorRun<CR>", {})
vim.api.nvim_set_keymap("n", "<Leader>ev", ":ExecutorToggleDetail<CR>", {})
