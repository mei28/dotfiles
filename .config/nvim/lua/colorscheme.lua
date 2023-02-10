vim.cmd [[ set background=dark ]]
vim.cmd [[ set termguicolors ]]

local utils = require('utils')
local M = {}

M.colorscheme2dir = {
  iceberg = 'iceberg.vim',
  edge = 'edge',
  nightfox = 'nightfox.nvim',
  tokyonight = 'tokyonight.nvim',
  hybrid = 'vim-hybrid',
  jellybeans = 'jellybeans.vim',
  pinkmare = 'pinkmare',
  hatsunemiku = 'vim-colors-hatsunemiku',
  catppuccin = 'nvim',
  kanagawa = 'kanagawa.nvim',
  kyotonight = 'kyotonight.vim',
  everforest = 'everforest',
  ayu = 'ayu-vim',
  sakura = 'sakura',
  onedark = 'onedark.nvim',
  gruvobx='gruvobx',
}


M.iceberg = function()
  vim.cmd.colorscheme "iceberg"
end

M.edge = function()
  vim.cmd.colorscheme "edge"
end

M.nightfox = function()
  -- vim.cmd.colorscheme "nightfox"
  vim.cmd.colorscheme "nordfox"
  -- vim.cmd.colorscheme "terafox"
  -- vim.cmd.colorscheme "duskfox"
end

M.tokyonight = function()
  vim.cmd.colorscheme "tokyonight"
end

M.hybrid = function()
  vim.cmd.colorscheme "hybrid"
end

M.jellybeans = function()
  vim.cmd.colorscheme "jellybeans"
end

M.pinkmare = function()
  vim.cmd.colorscheme "pinkmare"
end

M.hatsunemiku = function()
  vim.cmd.colorscheme "hatsunemiku"
end

M.catppuccin = function()
  vim.cmd.colorscheme "catppuccin"
end
M.kanagawa = function()
  vim.cmd.colorscheme "kanagawa"
end

M.kyotonight = function()
  vim.cmd.colorscheme "kyotonight"
end

M.everforest = function()
  vim.cmd.colorscheme 'everforest'
end

M.ayu = function()
  vim.cmd.colorscheme 'ayu'
end

M.sakura = function()
  vim.cmd.colorscheme 'sakura'
end

M.onedark = function()
  vim.cmd.colorscheme 'onedark'
end


M.gruvobx = function ()
  vim.cmd.colorscheme 'gruvbox'
end

M.randColorScheme = function()
  local colorscheme = utils.rand_element(vim.tbl_keys(M.colorscheme2dir))

  if not vim.tbl_contains(vim.tbl_keys(M), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg)
    return
  end

  -- local status = utils.add_pack(M.colorscheme2dir[colorscheme])
  -- if not status then
  --   local msg = string.format("colorscheme %s is not installed. Run PackerSync to install", colorscheme)
  --   vim.notify(msg)
  -- end
  M[colorscheme]()

  if vim.g.loggin_level == 'debug' then
    local msg = "colorscheme: " .. colorscheme
    vim.notify(msg)
  end

end

-- vim.g.loggin_level = 'debug'
M.randColorScheme()
