local spec = {
  -- -- fold
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = { 'ModeChanged' },
  }

}
return spec
