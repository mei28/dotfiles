-- load plugins.lua
require'colorscheme'
require'plugins'
require'config'
require'keymap'
require'lualine-config'
require'lsp-config'
require'ddc-config'
require'ale-config'

-- auto compile plugins
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]
