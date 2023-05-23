local status, trouble = pcall(require, 'trouble')

if not status then return end

local set = vim.keymap.set
trouble.setup()
set("n", "tt", "<cmd>TroubleToggle<cr>")
set("n", "tw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
set("n", "td", "<cmd>TroubleToggle document_diagnostics<cr>")
set("n", "tl", "<cmd>TroubleToggle loclist<cr>")
set("n", "tq", "<cmd>TroubleToggle quickfix<cr>")
