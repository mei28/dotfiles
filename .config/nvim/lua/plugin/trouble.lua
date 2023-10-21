local spec = {
  {
    'folke/trouble.nvim',
    config = function()
      local status, trouble = pcall(require, 'trouble')
      if not status then return end
      trouble.setup()
    end,
    keys = {
      { "tt", "<cmd>TroubleToggle<cr>" },
      { "tw", "<cmd>TroubleToggle workspace_diagnostics<cr>" },
      { "td", "<cmd>TroubleToggle document_diagnostics<cr>" },
      { "tl", "<cmd>TroubleToggle loclist<cr>" },
      { "tq", "<cmd>TroubleToggle quickfix<cr>" },
    }
  }
}

return spec
