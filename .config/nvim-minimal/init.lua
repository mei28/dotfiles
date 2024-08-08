local illuminate = {
  "mei28/luminate.nvim",
  -- dir = '~/Documents/luminate.nvim',
  -- event = "VeryLazy",
  -- keys = { { 'y' }, { 'p' }, { 'u' }, { 'U' }, { '<C-r>' } },
  keys = { { 'Y', function() vim.cmd('normal! y$') end } },
  config = function()
    require 'luminate'.setup({
    })
  end,
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- latest stable release
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Lazy plugin spec: https://github.com/folke/lazy.nvim#-plugin-spec
local lazy = require("lazy")
lazy.setup({ illuminate, }, {})
