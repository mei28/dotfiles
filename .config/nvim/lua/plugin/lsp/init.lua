local spec = {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		config = function()
			---@diagnostic disable: redefined-local
			local status, mason = pcall(require, "mason")
			if not status then
				return
			end

			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local servers = {
				"lua_ls",
				-- 'bashls',
				"html",
				"clangd",
				"rust_analyzer",
				"quick_lint_js",
				"ts_ls",
				"jsonls",
				"efm",
				"pyright",
				"svelte",
				"tailwindcss",
				"emmet_ls",
				"typos_lsp",
				"nil_ls",
				"gopls",
			}

			local status, mason_lspconfig = pcall(require, "mason-lspconfig")
			if not status then
				return
			end
			mason_lspconfig.setup({
				automatic_installation = true,
				ensure_installed = servers,
			})

			-- local status, lspconfig = pcall(require, 'lspconfig')
			-- if not status then return end

			local status, navic = pcall(require, "nvim-navic")
			if not status then
				return
			end
			local vlc = vim.lsp.config

			-- https://github.com/neovim/neovim/issues/23291#issuecomment-1523243069
			-- https://github.com/neovim/neovim/pull/23500#issuecomment-1585986913
			-- pyright asks for every file in every directory to be watched,
			-- so for large projects that will necessarily turn into a lot of polling handles being created.
			-- sigh
			local ok, wf = pcall(require, "vim.lsp._watchfiles")
			if ok then
				wf._watchfunc = function()
					return function() end
				end
			end

			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			local status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if not status then
				print("cmp_nvim_lsp not found")
				return
			end

			local capabilities = cmp_nvim_lsp.default_capabilities()
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.enable(servers)

			-- Global mappings
			local set = vim.keymap.set
			set("n", "[d", function()
				vim.diagnostic.goto_prev({ count = 1, float = true })
			end)
			set("n", "]d", function()
				vim.diagnostic.goto_next({ count = -1, float = true })
			end)
			set("n", "<Leader>e", vim.diagnostic.open_float)
			set("n", "<Leader>q", vim.diagnostic.setloclist)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
					local bufopts = { buffer = ev.buf }
					-- Mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					set("n", "gD", vim.lsp.buf.declaration, bufopts)
					set("n", "gd", vim.lsp.buf.definition, bufopts)
					set("n", "gi", vim.lsp.buf.implementation, bufopts)
					set("n", "gr", vim.lsp.buf.references, bufopts)
					set("n", "H", vim.lsp.buf.hover, bufopts)
					set("n", "K", vim.lsp.buf.signature_help, bufopts)
					set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
					set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
					set("n", "<Leader>lf", "<CMD>lua vim.lsp.buf.format({async=true})<CR>", bufopts)
					set("n", "cc", vim.lsp.buf.incoming_calls, bufopts)

					local client = vim.lsp.get_clients()[1]
					if client.server_capabilities.documentSymbolProvider then
						navic.attach(client, ev.buf)
					end

					-- inlay hint
					local bufnr = ev.buf
					local supports_inlay_hints = client and client.server_capabilities.inlayHintProvider
					vim.g.inlay_hints_enabled = false
					if supports_inlay_hints then
						vim.lsp.inlay_hint.enable(false, { bufnr })
						-- Inlay Hintsの表示状態をトグルするコマンド
						vim.api.nvim_create_user_command("ToggleInlayHint", function()
							vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
							if vim.g.inlay_hints_enabled then
								vim.lsp.inlay_hint.enable(true, { bufnr })
							else
								vim.lsp.inlay_hint.enable(false, { bufnr })
							end
						end, { desc = "Toggle Inlay Hints" })

						-- Inlay Hintsを有効にするコマンド
						vim.api.nvim_create_user_command("EnableInlayHint", function()
							vim.g.inlay_hints_enabled = true
							vim.lsp.inlay_hint.enable(true, { bufnr })
						end, { desc = "Enable Inlay Hints" })

						-- Inlay Hintsを無効にするコマンド
						vim.api.nvim_create_user_command("DisableInlayHint", function()
							vim.g.inlay_hints_enabled = false
							vim.lsp.inlay_hint.enable(false, { bufnr })
						end, { desc = "Disable Inlay Hints" })

						-- InsertEnterとInsertLeaveの自動コマンドを作成
						vim.api.nvim_create_autocmd("InsertEnter", {
							callback = function()
								if vim.g.inlay_hints_enabled then
									vim.lsp.inlay_hint.enable(false, { bufnr })
								end
							end,
							buffer = bufnr,
						})
						vim.api.nvim_create_autocmd("InsertLeave", {
							callback = function()
								if vim.g.inlay_hints_enabled then
									vim.lsp.inlay_hint.enable(true, { bufnr })
								end
							end,
							buffer = bufnr,
						})
					end
				end,
			})

			-- LSP handlers, virtualtext
			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })
			vim.api.nvim_create_autocmd("InsertEnter", {
				callback = function()
					vim.diagnostic.hide(nil, vim.api.nvim_get_current_buf())
				end,
			})
			vim.api.nvim_create_autocmd("InsertLeave", {
				callback = function()
					vim.diagnostic.show(nil, vim.api.nvim_get_current_buf())
				end,
			})

			-- https://zenn.dev/vim_jp/articles/c62b397647e3c9 エラー警告ヒントの順番を固定
			vim.diagnostic.config({ severity_sort = true })
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = { "MasonToolsUpdate" },
	},
}

return spec
