local spec = {

  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      local status, hlslens = pcall(require, 'hlslens')
      if not status then return end
      hlslens.setup()
      require("scrollbar.handlers.search").setup({})
    end,
    lazy = false,
    keys = {
      { 'n',  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { 'N',  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { '*',  [[*<Cmd>lua require('hlslens').start()<CR>]] },
      { '#',  [[#<Cmd>lua require('hlslens').start()<CR>]] },
      { 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]] },
      { 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]] },
    }
  }

}

return spec
