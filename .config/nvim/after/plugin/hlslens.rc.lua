local status, hlslens = pcall(require, 'hlslens')
if not status then return end
hlslens.setup()

local set = vim.keymap.set

set('n', 'n',
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
set('n', 'N',
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]])
set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]])
set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]])
set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]])
