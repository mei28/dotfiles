local status, sidebar = pcall(require, "sidebar-nvim")
if not status then return end
sidebar.setup({
    open = true,
    sections = {'git','diagnostics','files'},
    files = {icon = "", show_hidden = false, ignored_paths = {"%.git$"}}
})

vim.keymap
    .set('n', '<leader>b', sidebar.toggle, {noremap = true, silent = true})
