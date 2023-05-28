local status, peek = pcall(require, 'peek')
if not status then
  return
end
vim.api.nvim_create_user_command('PeekOpen', peek.open, {})
vim.api.nvim_create_user_command('PeekClose', peek.close, {})
vim.api.nvim_create_user_command('Peek', function() if peek.is_open() then peek.close() else peek.open() end end, {})
