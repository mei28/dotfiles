local status, null_ls = pcall(require, "null-ls")
if not status then
	return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

local on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.keymap.set("n", "<Leader>lf", function()
			vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
		end, { buffer = bufnr, desc = "[lsp] format" })

		-- format on save
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
		vim.api.nvim_create_autocmd(event, {
			buffer = bufnr,
			group = group,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, async = async })
			end,
			desc = "[lsp] format on save",
		})
	end
	if client.supports_method("textDocument/rangeFormatting") then
		vim.keymap.set("x", "<Leader>lf", function()
			vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
		end, { buffer = bufnr, desc = "[lsp] format" })
	end
end

-- add
local status, mason_package = pcall(require, "mason-core.package")
if not status then
	return
end
local status, mason_registry = pcall(require, "mason-registry")
if not status then
	return
end

local null_sources = {
	-- null_ls.builtins.formatting.beautysh,
	-- null_ls.builtins.formatting.fixjson,
	-- null_ls.builtins.formatting.black,
	-- null_ls.builtins.formatting.isort,
	-- null_ls.builtins.formatting.stylua,
	-- null_ls.builtins.formatting.rustfmt,
}

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
	on_attach = on_attach,
})
