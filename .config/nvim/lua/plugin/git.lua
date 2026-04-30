local spec = {

	-- -- git
	{
		"dinhhuy258/git.nvim",
		keys = {
			{ "<Leader>gb", desc = "Git: git blame" },
			{ "<Leader>go", desc = "Git: go github" },
		},
		config = function()
			local status, git = pcall(require, "git")
			if not status then
				return
			end
			git.setup({
				keymaps = {
					-- Open blame window
					blame = "<Leader>gb",
					-- Open file/folder in git repository
					browse = "<Leader>go",
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		-- event = { 'BufNewFile', 'BufRead' },
		lazy = false,
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "│" },
					delete = { text = "-" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
			})
			-- require("scrollbar.handlers.gitsigns").setup()
		end,
	},
	{
		"Tronikelis/conflict-marker.nvim",
		keys = {
			{ "[x", desc = "Git: jump to previous conflict marker" },
			{ "]x", desc = "Git: jump to next conflict marker" },
			{ "co", desc = "Git: choose ours" },
			{ "ct", desc = "Git: choose theirs" },
			{ "cb", desc = "Git: choose both" },
			{ "cn", desc = "Git: choose none" },
		},
		init = function()
			local subcommands = {
				"ours",
				"theirs",
				"both",
				"none",
				"diffOursTheirs",
				"diffBaseOurs",
				"diffBaseTheirs",
				"hlRefresh",
			}
			vim.api.nvim_create_user_command("Conflict", function(opts)
				pcall(vim.api.nvim_del_user_command, "Conflict")
				require("conflict-marker").check(0)
				if opts.args ~= "" then
					vim.cmd("Conflict " .. opts.args)
				end
			end, {
				nargs = 1,
				desc = "conflict-marker: resolve / diff conflicts",
				complete = function(arg_lead)
					return vim.tbl_filter(function(s)
						return vim.startswith(s, arg_lead)
					end, subcommands)
				end,
			})
		end,
		config = function()
			require("conflict-marker").setup({
				highlights = true,
				on_attach = function(conflict)
					local MID = "^=======$"

					vim.keymap.set("n", "[x", function()
						vim.cmd("?" .. MID)
					end, { buffer = conflict.bufnr })

					vim.keymap.set("n", "]x", function()
						vim.cmd("/" .. MID)
					end, { buffer = conflict.bufnr })

					local map = function(key, fn)
						vim.keymap.set("n", key, fn, { buffer = conflict.bufnr })
					end

					-- or you can map these to <cmd>ChooseOurs<cr>

					map("co", function()
						conflict:choose_ours()
					end)
					map("ct", function()
						conflict:choose_theirs()
					end)
					map("cb", function()
						conflict:choose_both()
					end)
					map("cn", function()
						conflict:choose_none()
					end)
				end,
			})
		end,
	},
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewFileHistory",
			"DiffviewOpen",
			"DiffviewClose",
		},
	},
	{ "rhysd/git-messenger.vim", cmd = { "GitMessenger" } },
	{
		"niuiic/git-log.nvim",
		dependencies = { "niuiic/core.nvim" },
		keys = {
			{
				"gL",
				function()
					require("git-log").check_log()
				end,
				mode = { "v", "n" },
				desc = "Git: show log",
			},
		},
	},
	{
		"FabijanZulj/blame.nvim",
		config = function()
			require("blame").setup()
		end,
		cmd = { "BlameToggle" },
	},
	{
		"Chen-Yulin/ColorfulDiff.nvim",
		event = { "BufNewFile", "BufRead" },
		config = function()
			local config = {
				colors = {
					diff = "#667700",
					origin = "#007766",
				},
			}
			require("colorful_diff").setup(config)
		end,
	},
}

return spec
