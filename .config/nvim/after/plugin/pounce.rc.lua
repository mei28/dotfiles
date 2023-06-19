local status, pounce = pcall(require, 'pounce')
if not status then return end
local map = vim.keymap.set

map({ "n", 'x' }, "s", function() require 'pounce'.pounce {} end)
map("n", "S", function() require 'pounce'.pounce { do_repeat = true } end)
map("o", "gs", function() require 'pounce'.pounce {} end)
map("n", "S", function() require 'pounce'.pounce { input = { reg = "/" } } end)
