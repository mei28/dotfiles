local status, trouble = pcall(require, 'trouble')

if not status then return end

local set = vim.keymap.set
trouble.setup()
set("n", "tt", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
set("n", "tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
set("n", "td", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
set("n", "tl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
set("n", "tq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
