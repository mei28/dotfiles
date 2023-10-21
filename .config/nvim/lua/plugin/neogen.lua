local spec = {
  -- annotaion comment
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
    cmd = { "Neogen" }
    -- Uncomment next line if you want to follow only stable versions
    -- version = '*'
  },
}

return spec
