local spec = {
  {
    -- dir = "~/Documents/luminate.nvim/",
    'mei28/luminate.nvim',
    branch = 'fix#8',
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
    -- dir = '~/Documents/instant_rename.nvim',
    'mei28/instant_rename.nvim',
    event = { 'ModeChanged', 'CmdlineChanged' }, -- for lazy loading
    config = function()
      require('instant_rename')
    end
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
  {
    'mei28/swapwords.nvim',
    config = function()
      require('swapwords')
    end,
    cmd = { "SwapWord" }

  },
  -- {
  --   'mei28/toggleqf.nvim',
  --   config = function() require('toggleqf').setup() end,
  --   keys = { '<C-g><C-o>', '<C-g><C-o>' },
  -- },
}

return spec
