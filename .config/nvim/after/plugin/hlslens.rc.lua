local kopts = { noremap = true, silent = true }
local set = vim.keymap.set

set('n', 'n',
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
set('n', 'N',
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

