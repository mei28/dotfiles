local status, navic = pcall(require, 'nvim-navic')
if not status then return end


vim.opt.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
