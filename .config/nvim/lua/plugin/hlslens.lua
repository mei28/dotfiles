local spec = {

  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      local status, hlslens = pcall(require, 'hlslens')
      if not status then return end
      hlslens.setup()
      require("scrollbar.handlers.search").setup({})
    end,
    dependencies = { 'rapan931/lasterisk.nvim' },
    keys = {
      { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      -- { '*',  [[*<Cmd>lua require('hlslens').start()<CR>]] },
      { '*', function()
        require("lasterisk").search()
        require('hlslens').start()
      end },
      { '#',  [[#<Cmd>lua require('hlslens').start()<CR>]] },
      -- { 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]] },
      { 'g*', function()
        require("lasterisk").search({ is_whole = false })
        require('hlslens').start()
      end },
      { 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]] },
    }
  },
  {
    'rapan931/lasterisk.nvim'
  }

}

return spec
