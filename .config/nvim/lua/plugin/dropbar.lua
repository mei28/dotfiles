local spec = {
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufNewFile', 'BufRead' },
    enabled = false, -- nvim 0.13 で BufModifiedSet deprecated。https://github.com/Bekaboo/dropbar.nvim/pull/280 マージ待ち
  },

}
return spec
