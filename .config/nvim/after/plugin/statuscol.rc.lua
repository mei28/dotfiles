local status, stc = pcall(require, 'statuscol')
if not status then return end
-- https://github.com/luukvbaal/statuscol.nvim

stc.setup()

-- vim.o.statuscolumn = "%@SignCb@%s%=%T%@NumCb@%r│%T"
