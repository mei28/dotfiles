local spec = {

	-- comment
	-- gc (operator/visual) と gcc (行) で切り替える。
	-- lazy = true が既定なので、トリガーを持たせないと読み込まれない。
	{
		"nvim-mini/mini.comment",
		keys = {
			{ "gc", mode = { "n", "x" } },
			{ "gcc", mode = "n" },
		},
		opts = {},
	},
}

return spec
