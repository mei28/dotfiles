local status, sidebar = pcall(require, "sidebar-nvim")
if not status then return end
sidebar.setup({
    sections = {'git', 'files', 'todos', 'diagnostics'},
    files = {icon = "", show_hidden = false, ignored_paths = {"%.git$"}},
    todos = {
        icon = "",
        ignored_paths = {'~'},
        -- ignore certain paths, this will prevent huge folders like $HOME to hog Neovim with TODO searching
        initially_closed = false
        -- whether the groups should be initially closed on start. You can manually open/close groups later.
    }

})

vim.keymap
    .set('n', '<leader>b', sidebar.toggle, {noremap = true, silent = true})

