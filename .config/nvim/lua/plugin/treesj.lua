local spec = {
  -- treesj
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local status, treesj = pcall(require, 'treesj')
      if not status then return end
      treesj.setup({ use_default_keymaps = false, })
    end,
    keys = {
      { "<Leader>m", function() require('treesj').toggle() end }
    },
  },

}

return spec
