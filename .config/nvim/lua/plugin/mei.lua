local spec = {
  {
    -- dir = "~/Documents/luminate.nvim/",
    'mei28/luminate.nvim',
    -- branch = 'fix#15',
    keys = { { 'u' }, { 'U' }, { '<C-r>' }, { 'p' }, { 'y' }, },
    config = function()
      require 'luminate'.setup({

      })
    end
  },
  {
    -- dir = "~/Documents/blink-bang-word-light.nvim",
    'mei28/blink-bang-word-light.nvim',
    event = { 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI' },
    config = function()
      require('blink-bang-word-light').setup({
        max_word_length = 100, -- if cursorword length > max_word_length then not highlight
        min_word_length = 2,   -- if cursorword length < min_word_length then not highlight
        excluded = {
          filetypes = {
            "TelescopePrompt",
          },
          buftypes = {
            -- "nofile",
            -- "terminal",
          },
          patterns = { -- the pattern to match with the file path
            -- "%.png$",
            -- "%.jpg$",
            -- "%.jpeg$",
            -- "%.pdf$",
            -- "%.zip$",
            -- "%.tar$",
            -- "%.tar%.gz$",
            -- "%.tar%.xz$",
            -- "%.tar%.bz2$",
            -- "%.rar$",
            -- "%.7z$",
            -- "%.mp3$",
            -- "%.mp4$",
          },
        },
        highlight = {
          underline = true,
          guifg = '#ffcc00', -- Foreground color
          guibg = '#333333', -- Background color
        },
        enabled = true,
      })
    end,

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
    -- dir = '~/Documents/instant-rename.nvim',
    'mei28/instant-rename.nvim',
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
