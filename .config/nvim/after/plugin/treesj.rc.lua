local status, treesj = pcall(require, 'treesj')
if not status then
  return
end

treesj.setup({
  use_default_keymaps = false,
})

vim.keymap.set('n', '<leader>m', require('treesj').toggle)
