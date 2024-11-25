local spec = {
  {
    'dmmulroy/tsc.nvim',
    cmd = { 'TSC' },
    config = function()
      require('tsc').setup {

      }
    end
  }
}

return spec
