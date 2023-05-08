local status, gitconflict = pcall(require, 'git-conflict')
if not status then return end

gitconflict.setup()

local set = vim.keymap.set

set('n', 'co', '<Plug>(git-conflict-ours)')
set('n', 'ct', '<Plug>(git-conflict-theirs)')
set('n', 'cb', '<Plug>(git-conflict-both)')
set('n', 'c0', '<Plug>(git-conflict-none)')
set('n', ']x', '<Plug>(git-conflict-prev-conflict)')
set('n', '[x', '<Plug>(git-conflict-next-conflict)')
