local spec = {
  {
    'folke/trouble.nvim',
    ft = 'qf',
    cmd = 'Trouble',
    config = function()
      local status, trouble = pcall(require, 'trouble')
      if not status then return end
      trouble.setup()
    end,
  }
}

return spec
