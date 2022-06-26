vim.api.nvim_set_keymap('n', '*', '*N', {noremap=true})
vim.api.nvim_set_keymap('n', '#', '#N', {noremap=true})

vim.api.nvim_set_keymap('i', '<C-f>', '<Right>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-b>', '<Left>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-p>', '<Up>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-n>', '<Down>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-a>', '<Home>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-e>', '<End>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-d>', '<Del>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-h>', '<BS>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-j>', '<F6>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-k>', '<F7>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-l>', '<F9>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<C-;>', '<F10>', {noremap=true, silent=true})

vim.api.nvim_set_keymap('c', '<C-f>', '<Right>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-b>', '<Left>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-p>', '<Up>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-n>', '<Down>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-a>', '<Home>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-e>', '<End>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-d>', '<Del>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-h>', '<BS>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-j>', '<F6>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-k>', '<F7>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-l>', '<F9>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('c', '<C-;>', '<F10>', {noremap=true, silent=true})

vim.api.nvim_set_keymap('n', '<C-f>', '<Right>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-b>', '<Left>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-p>', ':bnext<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-n>', ':bprev<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-a>', '<Home>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-e>', '<End>', {noremap=true, silent=true})

vim.api.nvim_set_keymap('n', '<C-o>', '<C-i>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-i>', '<C-o>', {noremap=true, silent=true})

-- x削除でヤンクしない
vim.api.nvim_set_keymap('n', 'x', '"_x', {noremap=true, silent=true})

-- ESC連打:noh
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':noh<CR>', {noremap=true, silent=true})

-- 行単位の移動
vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', 'gj', 'j', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', 'gk', 'k', {noremap=true, silent=true})

-- 補完時に改行しない
vim.keymap.set('i', '<expr><CR>', function()
    return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, {expr = true})
vim.o.completeopt="menuone,noinsert"

-- 上下を決める
vim.keymap.set('i', '<TAB>', function()
    return vim.fn.pumvisible() == 1 and '<Down>' or '<TAB>'
end, {expr = true})
vim.keymap.set('i', '<S-TAB>', function()
    return vim.fn.pumvisible() == 1 and '<Up>' or '<S-TAB>'
end, {expr = true})

-- ターミナルモードでコマンドを戻る
-- vim.api.nvim_set_keymap('t', '<Esc>', '<C-\><C-n>', {noremap=true, silent=true})

-- inser, command modeでも<C-v>する
-- vim.api.nvim_set_keymaps('i', '<C-v>', 'printf("<C-r><C-o>%s", has("linux") \|\| has("unix") ? "+" : "*")', {noremap=true, silent=true, expr=true})
-- vim.api.nvim_set_keymaps('c', '<C-v>', 'printf("<C-r><C-o>%s", has("linux") \|\| has("unix") ? "+" : "*")', {noremap=true, silent=true, expr=true})

-- visualモードでの貼り付けをバッファに登録しないようにする
vim.api.nvim_set_keymap('x', 'p', '"_dP', {noremap=true, silent=true})



