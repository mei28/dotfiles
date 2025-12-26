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
	-- {
	--   'wsdjeg/scrollbar.vim',
	--   event = { "CursorMoved", "CursorHold" },
	--   config = function()
	--     require('scrollbar').setup({
	--       max_size = 10,
	--       min_size = 5,
	--       width = 1,
	--       right_offset = 1,
	--       excluded_filetypes = {
	--         'startify',
	--         'git-commit',
	--         'leaderf',
	--         'NvimTree',
	--         'tagbar',
	--         'defx',
	--         'neo-tree',
	--         'qf',
	--       },
	--       shape = {
	--         head = '',
	--         body = '█',
	--         tail = '',
	--       },
	--       highlight = {
	--         head = 'Normal',
	--         body = 'Normal',
	--         tail = 'Normal',
	--       },
	--     })
	--   end,
	-- },
}

return spec
