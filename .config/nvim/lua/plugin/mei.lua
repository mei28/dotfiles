local spec = {
  {
    'mei28/luminate.nvim',
    event = { 'TextYankPost' },
    config = function()
      require 'luminate'.setup({
        timeout = 500,
        HIGHLIGHT_THRESHOLD = 0.5,
      })
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
    'mei28/toggleqf.nvim',
    config = function() require('toggleqf').setup() end,
    keys = { '<C-g><C-o>', '<C-g><C-o>' },
  },
  {
    'mei28/swapwords.nvim',
    config = function()
      require('swapwords')
    end,
    cmd = { "SwapWord" }

  },
}

return spec
