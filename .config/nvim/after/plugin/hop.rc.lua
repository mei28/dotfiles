local status, hop = pcall(require, 'hop')
if not status then return end

hop.setup({
  keys = 'asdghklqwertyuiopzxcvbnmfj'
})

local set = vim.keymap.set
local opts = { remap = true }

-- place this in one of your configuration file(s)
set('n', 'f',
  "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>"
  , opts)
set('n', 'F',
  "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>"
  , opts)
set('n', 't',
  "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>"
  , opts)
set('n', 'T',
  "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>"
  , opts)
set('n', '<leader><leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", opts)
set('n', '<leader><leader>w', "<cmd>lua require'hop'.hint_words()<cr>", opts)
set('n', '<leader><leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", opts)
