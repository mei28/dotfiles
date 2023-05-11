local status, uterm = pcall(require, "ugaterm")
if not status then return end
local set = vim.keymap.set

uterm.setup {}

set({ 'n', 't' }, '<C-`>', "<CMD>UgatermToggle<CR>")
set({ 'n', 't' }, '<C-t>', "<CMD>UgatermToggle<CR>")
