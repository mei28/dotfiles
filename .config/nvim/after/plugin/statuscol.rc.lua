local status, stc = pcall(require, 'statuscol')
if not status then return end
-- https://github.com/luukvbaal/statuscol.nvim


local builtin = require("statuscol.builtin")

stc.setup()
