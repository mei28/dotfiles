local spec = {
	{
		"nvim-mini/mini.pairs",
		version = false,
		-- mini.pairs only maps <CR> when nothing else has, and nvim-cmp claims it
		-- first on the same InsertEnter. MiniPairs.cr() is therefore inactive:
		-- <CR> inside {} does not expand the pair across three lines.
		event = { "InsertEnter", "CursorMoved", "ModeChanged" },
		config = function()
			require("mini.pairs").setup({})
		end,
	},
	{
		"echasnovski/mini.align",
		version = false,
		event = { "CursorMoved", "ModeChanged" },
		config = function()
			require("mini.align").setup({})
		end,
	},
	{
		"echasnovski/mini.diff",
		version = false,
		event = { "CursorMoved", "ModeChanged" },
		config = function()
			require("mini.diff").setup({})
		end,
		keys = { { "gh" }, { "gH" }, { "[H" }, { "[h" }, { "]H" }, { "]h" } },
	},
}

return spec
