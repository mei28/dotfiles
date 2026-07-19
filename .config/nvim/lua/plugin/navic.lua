-- winbar の描画は barbecue.nvim が担当し、barbecue が nvim-navic を
-- dependencies として読み込む。ここで vim.opt.winbar を直接設定すると
-- barbecue の描画と二重になるため、プラグインの宣言だけに留める。
local spec = {
  {
    'SmiteshP/nvim-navic',
    event = { 'BufNewFile', 'BufRead' },
  }
}

return spec
