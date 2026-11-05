local spec = {
	-- {
	--   "petertriho/nvim-scrollbar",
	--   event = { 'BufNewFile', 'BufRead' },
	--   config = function()
	--     require('scrollbar').setup()
	--   end
	-- },

	{
		"tonymajestro/smart-scrolloff.nvim",
		event = { "CursorMoved", "CursorHold" },
		opts = {
			scrolloff_percentage = 0.2,
		},
	},
	{
		"petertriho/nvim-scrollbar",
		-- v2 replaces v1 on main on 2026-11-16 (petertriho/nvim-scrollbar#121); drop this line then.
		branch = "refactor/v2",
		event = { "CursorMoved", "CursorHold" },
		opts = {
			-- Search marks are built in since v2; only gitsigns needs enabling.
			providers = { gitsigns = true },
			scrollbar = {
				-- The float is opaque at winblend 0 and hides the last text column on every row.
				-- Blending lets blank track cells show the text through; marks still cover it.
				window = { wo = { winblend = 100 } },
			},
		},
	},
}

return spec
