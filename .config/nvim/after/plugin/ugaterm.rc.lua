local status, uterm = pcall(require, "ugaterm")
if not status then return end

uterm.setup {}

vim.keymap.set('n', '<C-`>', "<CMD>UgatermToggle<CR>")
