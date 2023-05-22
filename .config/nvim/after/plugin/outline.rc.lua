local status, outline = pcall(require, 'symbols-outline')
if not status then return end
outline.setup({
  position = 'right',
  auto_preview = true,
  auto_close = true,
  show_number = true,
  show_symbol_details = true,
})
local set = vim.keymap.set
set('n', ';a', '<CMD>SymbolsOutline<CR>')
