local status, trouble = pcall(require, 'trouble')

if not status then  return end

trouble.setup()
vim.keymap.set("n", "tt", "<cmd>TroubleToggle<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "tw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "td", "<cmd>TroubleToggle document_diagnostics<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "tl", "<cmd>TroubleToggle loclist<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "tq", "<cmd>TroubleToggle quickfix<cr>",
  { silent = true, noremap = true }
)

