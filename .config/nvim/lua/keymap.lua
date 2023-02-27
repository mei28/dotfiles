local set = vim.keymap.set
local opts = { noremap = true, silent = true }

set('n', '*', '*N', opts)
set('n', '#', '#N', opts)

set('i', '<C-f>', '<Right>', opts)
set('i', '<C-b>', '<Left>', opts)
set('i', '<C-p>', '<Up>', opts)
set('i', '<C-n>', '<Down>', opts)
set('i', '<C-a>', '<Home>', opts)
set('i', '<C-e>', '<End>', opts)
set('i', '<C-d>', '<Del>', opts)
set('i', '<C-h>', '<BS>', opts)
set('i', '<C-j>', '<F6>', opts)
set('i', '<C-k>', '<F7>', opts)
set('i', '<C-l>', '<F9>', opts)
set('i', '<C-;>', '<F10>', opts)

set('c', '<C-f>', '<Right>', opts)
set('c', '<C-b>', '<Left>', opts)
set('c', '<C-p>', '<Up>', opts)
set('c', '<C-n>', '<Down>', opts)
set('c', '<C-a>', '<Home>', opts)
set('c', '<C-e>', '<End>', opts)
set('c', '<C-d>', '<Del>', opts)
set('c', '<C-h>', '<BS>', opts)
set('c', '<C-j>', '<F6>', opts)
set('c', '<C-k>', '<F7>', opts)
set('c', '<C-l>', '<F9>', opts)
set('c', '<C-;>', '<F10>', opts)

set('n', '<C-f>', '<Right>', opts)
set('n', '<C-b>', '<Left>', opts)
set('n', '<C-a>', '<Home>', opts)
set('n', '<C-p>', ':bnext<CR>', opts)
set('n', '<C-n>', ':bprev<CR>', opts)
set('n', '<C-e>', '<End>', opts)

-- set('n', '<C-o>', '<C-i>', opts)
-- set('n', '<C-i>', '<C-o>', opts)

-- x削除でヤンクしない
set('n', 'x', '"_x', opts)

-- ESC連打:noh
set('n', '<Esc><Esc>', ':noh<CR>', opts)

-- 分割windowの移動
set('n', '<Leader>j', '<C-w>j', opts)
set('n', '<Leader>k', '<C-w>k', opts)
set('n', '<Leader>l', '<C-w>l', opts)
set('n', '<Leader>hh', '<C-w>h', opts)

-- 行単位の移動
set('n', 'j', 'gj', opts)
set('n', 'k', 'gk', opts)
set('n', 'gj', 'j', opts)
set('n', 'gk', 'k', opts)

-- 補完時に改行しない
-- vim.cmd [[inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"]]
set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true, noremap = true, silent = true })

-- 上下を決める
-- vim.keymap.set('i', '<TAB>', function()
--     return vim.fn.pumvisible() == 1 and '<Down>' or '<TAB>'
-- end, {expr = true, noremap=true})
-- vim.keymap.set('i', '<S-TAB>', function()
--     return vim.fn.pumvisible() == 1 and '<Up>' or '<S-TAB>'
-- end, {expr = true, noremap=true})

-- vim.keymap.set('i', '<C-n>', function()
--     return vim.fn.pumvisible() == 1 and '<Down>' or '<C-n>'
-- end, {expr = true, noremap=true})
-- vim.keymap.set('i', '<C-p>', function()
--     return vim.fn.pumvisible() == 1 and '<Up>' or '<C-p>'
-- end, {expr = true, noremap=true})

-- ターミナルモードでコマンドを戻る
set('t', '<Esc>', [[<C-\><C-n>]], opts)

-- inser, command modeでも<C-v>する
set('i', '<C-v>', '<C-r><C-o>0', opts)
set('c', '<C-v>', '<C-r><C-o>0', opts)

-- visualモードでの貼り付けをバッファに登録しないようにする
set('x', 'p', '"_dP', opts)

-- 新しいタブを作る,消す
set('n', 'te', ':tabedit ', opts)
set('n', 'tc', ':tabclose<CR>', opts)
