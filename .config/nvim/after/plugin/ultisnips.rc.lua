local status, ultisnips = pcall(require, 'ultisnips')
if not status then
  return
end

vim.g.UltiSnipsExpandTrigger="<C-g><C-g>"
vim.g.UltiSnipsJumpForwardTrigger="<C-f>"
vim.g.UltiSnipsJumpBackwardTrigger="<C-b>"
vim.g.UltiSnipsEditSplit="vertical"
