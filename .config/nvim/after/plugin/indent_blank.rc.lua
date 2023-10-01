vim.opt.list = true
vim.opt.listchars:append "space: "
-- vim.opt.listchars:append "eol:↴"


local status, ibl = pcall(require, 'ibl')
if not status then
  return
end
ibl.setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line = true,
}
