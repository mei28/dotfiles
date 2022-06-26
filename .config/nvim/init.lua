-- load plugins.lua
require'plugins'
require'config'
require'keymap'

-- auto compile plugins
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]
