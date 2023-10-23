local spec = {
  {
    'folke/trouble.nvim',
    config = function()
      local status, trouble = pcall(require, 'trouble')
      if not status then return end
      trouble.setup()
    end,
    keys = {
      { "tt", "<CMD>TroubleToggle<CR>" },
      { "tw", "<CMD>TroubleToggle workspace_diagnostics<CR>" },
      { "td", "<CMD>TroubleToggle document_diagnostics<CR>" },
      { "tl", "<CMD>TroubleToggle loclist<CR>" },
      { "tq", "<CMD>TroubleToggle quickfix<CR>" },
    }
  }
}

return spec
