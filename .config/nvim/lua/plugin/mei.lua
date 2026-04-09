local spec = {
	{
		-- dir = "~/Documents/luminate.nvim/.gardener/refactor/",
		"mei28/luminate.nvim",
		branch = "refactor",
		keys = { { "u" }, { "U" }, { "<C-r>" }, { "p" }, { "y" }, { "yy" } },
		event = { "ModeChanged" },
		config = function()
			require("luminate").setup({
				-- highlight_threshold = 1.9,
				-- yank = {
				--   guibg = "#2d4f67",
				--   fg = "#ebcb8b",
				--   enabled = true,
				-- },
				-- paste = {
				--   guibg = "#000067",
				--   fg = "#eb0000",
				--   enabled = true,
				-- },
				-- undo = {
				--   guibg = "#2d4f67",
				--   fg = "#00cb00",
				--   enabled = true,
				-- },
				-- redo = {
				--   guibg = "#2d4f67",
				--   fg = "#ff008b",
				--   enabled = true,
				-- },
			})
		end,
	},
	{
		-- dir = "~/Documents/blink-bang-word-light.nvim",
		"mei28/blink-bang-word-light.nvim",
		branch = "feat/visual-mode-highlight",
		event = { "CursorHold", "CursorMoved" },
		config = function()
			require("blink-bang-word-light").setup({
				max_word_length = 100, -- if cursorword length > max_word_length then not highlight
				min_word_length = 2, -- if cursorword length < min_word_length then not highlight
				excluded = {
					filetypes = {
						"TelescopePrompt",
					},
					buftypes = {
						-- "nofile",
						-- "terminal",
					},
					patterns = { -- the pattern to match with the file path
						-- "%.png$",
						-- "%.jpg$",
						-- "%.jpeg$",
						-- "%.pdf$",
						-- "%.zip$",
						-- "%.tar$",
						-- "%.tar%.gz$",
						-- "%.tar%.xz$",
						-- "%.tar%.bz2$",
						-- "%.rar$",
						-- "%.7z$",
						-- "%.mp3$",
						-- "%.mp4$",
					},
				},
				highlight = {
					underline = true,
					guifg = "#ffcc00", -- Foreground color
					guibg = "#333333", -- Background color
				},
				enabled = true,
			})
		end,
	},
	{
		-- dir = "~/Documents/qfc.nvim/",
		"mei28/qfc.nvim",
		config = function()
			require("qfc").setup({
				timeout = 3000,
				enabled = true,
				targets = {
					{ buftype = "quickfix", timeout = 3000 },
					{ filetype = "Outline", timeout = 3000 },
					{ filetype = "qf", timeout = 3000 },
					{ filetype = "undotree", timeout = 2000 },
					{ filetype = "messages", timeout = 3000 },
					-- { filetype = "Avante",       timeout = 5000 },
					-- { filetype = "copilot-chat", timeout = 5000 },
				},
			})
		end,
		ft = { "qf", "Outline", "undotree", "copilot-chat", "messages" },
		cmd = { "QFC" },
	},
	{
		-- dir = '~/Documents/instant-rename.nvim',
		"mei28/instant-rename.nvim",
		event = { "ModeChanged", "CmdlineChanged" }, -- for lazy loading
		config = function()
			require("instant_rename")
		end,
	},
	{
		-- dir = '/Users/mei/Documents/BigSheetGardna.nvim',
		"mei28/BigSheetGardna.nvim",
		event = { "BufNewFile", "BufRead" },
		config = function()
			require("big_sheet_gardna").setup({
				notify = false, -- Show notification for large files
				size_threshold = 1.5 * 1024 * 1024, -- Set size threshold (default: 1.5MB)
			})
		end,
	},
	{
		-- dir = '~/Documents/weview.nvim',
		"mei28/weview.nvim",
		cmd = { "Weview" },
		config = function()
			require("weview").setup({
				search_urls = {
					Google = "https://www.google.com/search?q=%s",
					GitHub = "https://github.com/search?q=%s",
					DeepL = "https://www.deepl.com/ja/translator#en/ja/%s",
				},
				aliases = {
					g = "Google",
					gh = "GitHub",
					d = "DeepL",
				},
				command_name = "Weview",
			})
		end,
	},
	{
		"mei28/slidev.nvim",
		-- dir = "~/Documents/slidev.nvim",
		config = function()
			require("slidev").setup({})
		end,
		cmd = {
			"SlidevPreview",
			"SlidevWatch",
			"SlidevStop",
			"SlidevStopAll",
			"SlidevExport",
			"SlidevBuild",
			"SlidevFormat",
			"SlidevStatus",
		},
	},
	{
		-- dir = "~/Documents/nvim-overleaf/",
		"mei28/nvim-overleaf",
		dependencies = {
			"vim-denops/denops.vim",
		},
		cmd = {
			"OverleafInit",
			"OverleafSync",
			"OverleafOpen",
			"OverleafStatus",
			"OverleafDisconnect",
			"OverleafLogLevel",
		},
		config = function()
			-- Optional: set cookie via environment variable
			-- vim.env.OVERLEAF_COOKIE = 'overleaf_session2=s%3A...'
		end,
	},

	-- {
	--   'mei28/codelens.nvim',
	--   config = function()
	--     require('codelens').setup({})
	--   end,
	--   keys = {
	--     {
	--       "<Leader>cl",
	--       "<CMD>lua require('codelens').toggle()<CR>",
	--       { 'n', 'v' },
	--     },
	--     {
	--       '<Leader>cu',
	--       "<CMD>lua require('codelens').show_cursor_info()<CR>",
	--       { 'n', 'v' },
	--     },
	--   },
	-- },
	-- {
	--   -- 'opps-guardian.nvim',
	--   dir = '~/Documents/opps-guardian.nvim',
	--   lazy = false,
	--   init = function() require('opps-guardian').init() end,
	-- },
	-- {
	--   'mei28/swapwords.nvim',
	--   config = function()
	--     require('swapwords')
	--   end,
	--   cmd = { "SwapWord" }
	--
	-- },
	-- {
	--   'mei28/toggleqf.nvim',
	--   config = function() require('toggleqf').setup() end,
	--   keys = { '<C-g><C-o>', '<C-g><C-o>' },
	-- },
}

return spec
