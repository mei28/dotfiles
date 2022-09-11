local status, hop = pcall(require,'hop')
if not status then return end

hop.setup({
  keys = 'asdghklqwertyuiopzxcvbnmfj'
})

-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('n', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
vim.api.nvim_set_keymap('n', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>", {})
vim.api.nvim_set_keymap('n', '<leader><leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader><leader>w', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader><leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
