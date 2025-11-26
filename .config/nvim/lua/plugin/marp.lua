local spec = {
	{
		"nwiizo/marp.nvim",
		config = function()
			require("marp").setup({
				marp_command = "~/.nix-profile/bin/marp",
			})
		end,
		cmd = {
			"MarpWatch",
			"MarpStop",
			"MarparpStopAll",
			"MarparpPreview",
			"MarparpList",
			"MarparpExport",
			"MarparpTheme",
			"MarparpSnippet",
			"MarparpInfo",
			"MarparpCopyPath",
			"MarparpDebug",
		},
	},
}

return spec
