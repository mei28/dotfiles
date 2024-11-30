local set = vim.keymap.set

set('n', '*', '*N')
set('n', '#', '#N')

set({ 'i', 'c', 'n' }, '<C-f>', '<Right>')
set({ 'i', 'c', 'n' }, '<C-b>', '<Left>')
set({ 'i', 'c', 'n' }, '<C-p>', '<Up>')
set({ 'i', 'c', 'n' }, '<C-n>', '<Down>')
set({ 'i', 'c', 'n' }, '<C-a>', '<Home>')
set({ 'i', 'c', 'n' }, '<C-e>', '<End>')
set({ 'i', 'c', 'n' }, '<C-d>', '<Del>')
set({ 'i', 'c', 'n' }, '<C-h>', '<BS>')


set('n', '<C-p>', '<CMD>bnext<CR>')
set('n', '<C-n>', '<CMD>bprev<CR>')

-- set('n', '<C-o>', '<C-i>')
-- set('n', '<C-i>', '<C-o>')

-- x削除でヤンクしない
set({ 'v', 'n' }, 'x', '"_x')
-- dl削除でヤンクしない
set('n', 'dl', '"_dd')

-- ESC連打:noh
set('n', '<Esc><Esc>', '<CMD>nohl<CR>')

-- 分割windowの移動
set('n', '<Leader>j', '<C-w>j')
set('n', '<Leader>k', '<C-w>k')
set('n', '<Leader>l', '<C-w>l')
set('n', '<Leader>h', '<C-w>h')

-- 行単位の移動
set({ "n", 'v' }, 'j', 'gj')
set({ "n", 'v' }, 'k', 'gk')
set({ "n", 'v' }, 'gj', 'j')
set({ "n", 'v' }, 'gk', 'k')

-- 補完時に改行しない
-- set('i', '<CR>', function()
--   return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
-- end, { expr = true })

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
set('t', '<Esc>', [[<C-\><C-n>]])

-- inser, command modeでも<C-v>する
set('i', '<C-v>', '<C-r><C-o>0')
set('c', '<C-v>', '<C-r><C-o>0')

-- visualモードでの貼り付けをバッファに登録しないようにする
set('x', 'p', '"_dP')

-- 新しいタブを作る,消す
set('n', 'te', '<CMD>tabedit ')
set('n', 'tc', '<CMD>tabclose<CR>')

set('n', 'q:', '<Nop>')
set('n', '<C-l>', 'zz')

set('n', 'dw', 'diw')
set('n', 'cw', 'ciw')


-- ref: https://blog.atusy.net/2023/12/09/gf-open-url/
vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    -- Neovim nightlyなら `vim.ui.open(cfile)` が便利。
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)
