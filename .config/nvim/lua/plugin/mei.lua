local spec = {
  {
    -- dir = "~/Documents/luminate.nvim/",
    'mei28/luminate.nvim',
    keys = { { 'u' }, { 'U' }, { '<C-r>' }, { 'p' }, { 'y' }, },
    config = function()
      require 'luminate'.setup()
    end
  },
  {
    -- dir = "~/Documents/qfc.nvim/",
    'mei28/qfc.nvim',
    config = function()
      require('qfc').setup({
        timeout = 3000,
        enabled = true,
      })
    end,
    ft = 'qf',
    cmd = { "QFC" }
  },
  {
    'mei28/codelens.nvim',
    config = function()
      require('codelens').setup({})
    end,
    keys = {
      {
        "<Leader>cl",
        "<CMD>lua require('codelens').toggle()<CR>",
        { 'n', 'v' },
      },
      {
        '<Leader>cu',
        "<CMD>lua require('codelens').show_cursor_info()<CR>",
        { 'n', 'v' },
      },
    },
  },
  -- {
  --   'mei28/toggleqf.nvim',
  --   config = function() require('toggleqf').setup() end,
  --   keys = { '<C-g><C-o>', '<C-g><C-o>' },
  -- },
  {
    'mei28/swapwords.nvim',
    config = function()
      require('swapwords')
    end,
    cmd = { "SwapWord" }

  },
}

return spec
