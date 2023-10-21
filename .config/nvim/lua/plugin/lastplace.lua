local spec = {

  {
    'ethanholz/nvim-lastplace',
    event = 'VeryLazy',
    config = function()
      local status, lastplace = pcall(require, 'nvim-lastplace')
      if not status then return end
      lastplace.setup {}
    end
  }

}

return spec
