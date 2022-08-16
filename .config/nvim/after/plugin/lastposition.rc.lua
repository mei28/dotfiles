local status, lastplace = pcall(require, 'nvim-lastplace')
if not status then return end
lastplace.setup {}
