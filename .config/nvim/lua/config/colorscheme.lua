vim.cmd [[ set background=dark ]]
vim.cmd [[ set termguicolors ]]

local colorschemes = {
  'iceberg',
  'edge',
  'nightfox',
  'tokyonight',
  'hybrid',
  'jellybeans',
  'hatsunemiku',
  'kanagawa',
  'kyotonight',
  'everforest',
  -- 'ayu',
  'sakura',
  'onedark',
  'gruvbox',
  'nightfly',
  'nightcity',
  'sweetie',
}

local function applyColorScheme(scheme)
  vim.cmd('colorscheme ' .. scheme)
end

randColorScheme = function()
  math.randomseed(os.time()) -- シードを現在の時刻で初期化
  local scheme = colorschemes[math.random(#colorschemes)]
  applyColorScheme(scheme)

  if vim.g.loggin_level == 'debug' then
    local msg = "colorscheme: " .. scheme
    vim.notify(msg)
  end
end

-- vim.g.loggin_level = 'debug'
randColorScheme()
