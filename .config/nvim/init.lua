-- load plugins.lua
require'plugins'
require'config'
require'keymap'
require'lualine-config'
require'lsp-config'
-- require'ddc-config'

-- auto compile plugins
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]