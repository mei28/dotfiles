-- Enable true color
vim.opt.termguicolors = true
local status, ccc = pcall(require, "ccc")
local mapping = ccc.mapping

ccc.setup({
  -- Your preferred settings
  -- Example: enable highlighter
  highlighter = {
    auto_enable = true,
    lsp = true,
  },
})
