local status, dial = pcall(require, 'dial')

if not status then return end

local set = vim.keymap.set
set("n", "g<C-a>", require("dial.map").inc_gnormal())
set("n", "g<C-x>", require("dial.map").dec_gnormal())
set("v", "g<C-a>", require("dial.map").inc_gvisual())
set("v", "g<C-x>", require("dial.map").dec_gvisual())
