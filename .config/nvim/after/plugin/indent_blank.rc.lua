vim.opt.list = true
vim.opt.listchars:append "space: "
-- vim.opt.listchars:append "eol:↴"


local status, indent_blankline = pcall(require, 'indent_blankline')
if not status then
  return
end
indent_blankline.setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line = true,
}
