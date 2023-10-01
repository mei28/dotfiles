vim.opt.list = true
vim.opt.listchars:append "space: "
-- vim.opt.listchars:append "eol:↴"


local status, ibl = pcall(require, 'ibl')
if not status then
  return
end
ibl.setup {
  -- indent = {
  --   char = "┊",
  -- },
}
