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
		event = { "CursorMoved", "CursorHold" },
		config = function()
			require("scrollbar").setup()
			require("scrollbar.handlers.search").setup()
			require("scrollbar.handlers.gitsigns").setup()
		end,
	},
}

return spec
