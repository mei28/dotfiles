local status, null_ls = pcall(require, 'null-ls')
if not status then return end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
  -- you can reuse a shared lspconfig on_attach callback here
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end
    })
  end
end


-- add
local status, mason_package = pcall(require, 'mason-core.package')
if not status then return end
local status, mason_registry = pcall(require, 'mason-registry')
if not status then return end

local null_sources = {}

for _, package in ipairs(mason_registry.get_installed_packages()) do
  local package_categories = package.spec.categories[1]
  if package_categories == mason_package.Cat.Formatter then
    table.insert(null_sources, null_ls.builtins.formatting[package.name])
  end
  if package_categories == mason_package.Cat.Linter then
    table.insert(null_sources, null_ls.builtins.diagnostics[package.name])
  end
end

-- null_ls.setup({
--   sources = {
--     -- null_ls.builtins.formatting.black, null_ls.builtins.diagnostics.flake8,
--     -- null_ls.builtins.diagnostics.mypy, null_ls.builtins.formatting.isort,
--     --
--     -- null_ls.builtins.diagnostics.luacheck,
--     -- null_ls.builtins.diagnostics.trail_space,
--     -- null_ls.builtins.formatting.lua_format
--
--     -- null_ls.builtins.formatting.prettier, null_ls.builtins.formatting.djhtml
--   }
--   -- on_attach = on_attach
-- })

null_ls.setup({
  sources = null_sources,
  on_attach = on_attach
})
