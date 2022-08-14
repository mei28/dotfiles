local status, null_ls = pcall(require, 'null-ls')
if not status then return end
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black, null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy, null_ls.builtins.formatting.isort,

        null_ls.builtins.diagnostics.luacheck,
        null_ls.builtins.diagnostics.trail_space,
        null_ls.builtins.formatting.lua_format,

        null_ls.builtins.formatting.prettier
    }
})

local bufopts = {noremap = true, silent = true}
vim.keymap.set('n', '<Leader>f', vim.lsp.buf.formatting, bufopts)
