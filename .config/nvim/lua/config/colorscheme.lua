vim.cmd [[ set background=dark ]]
vim.cmd [[ set termguicolors ]]

-- 起動時にランダム選択する候補。
-- インストール自体は plugin/colorschemes.lua が行う。リポジトリ名から
-- colorscheme 名は機械的に導けない（cocopon/iceberg.vim -> iceberg）ため、
-- 両方を手で対応させる必要がある。プラグインを増減したらこちらも更新すること。
-- ayu は plugin 側にあるが、意図的に候補から外している。
local colorschemes = {
  'iceberg',
  'edge',
  'nightfox',
  'tokyonight',
  'hybrid',
  'jellybeans',
  'pinkmare',
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
  '0x96f'
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
