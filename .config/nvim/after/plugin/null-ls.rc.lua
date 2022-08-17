local status, null_ls = pcall(require, 'null-ls')
if not status then return end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
    -- you can reuse a shared lspconfig on_attach callback here
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function() vim.lsp.buf.format({bufnr = bufnr}) end
        })
    end
end

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black, null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy, null_ls.builtins.formatting.isort,

        null_ls.builtins.diagnostics.luacheck,
        null_ls.builtins.diagnostics.trail_space,
        null_ls.builtins.formatting.lua_format

        -- null_ls.builtins.formatting.prettier, null_ls.builtins.formatting.djhtml
    },
    on_attach = on_attach
})
