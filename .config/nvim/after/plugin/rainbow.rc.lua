local status, rainbow = pcall(require, 'rainbow')
if not status then
  return 
end

vim.g.rainbow_active=1
