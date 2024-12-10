local spec = {
  {
    -- dir = "~/Documents/luminate.nvim/",
    'mei28/luminate.nvim',
    -- branch = 'fix#15',
    keys = { { 'u' }, { 'U' }, { '<C-r>' }, { 'p' }, { 'y' }, },
    event = { 'ModeChanged' },
    config = function()
      require 'luminate'.setup({
        -- highlight_threshold = 1.9,
        -- yank = {
        --   guibg = "#2d4f67",
        --   fg = "#ebcb8b",
        --   enabled = true,
        -- },
        -- paste = {
        --   guibg = "#000067",
        --   fg = "#eb0000",
        --   enabled = true,
        -- },
        -- undo = {
        --   guibg = "#2d4f67",
        --   fg = "#00cb00",
        --   enabled = true,
        -- },
        -- redo = {
        --   guibg = "#2d4f67",
        --   fg = "#ff008b",
        --   enabled = true,
        -- },
        --
      })
    end
  },
  {
    -- dir = "~/Documents/blink-bang-word-light.nvim",
    'mei28/blink-bang-word-light.nvim',
    event = { 'CursorHold', 'CursorMoved' },
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
    -- dir = '/Users/mei/Documents/BigSheetGardna.nvim',
    'mei28/BigSheetGardna.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      require("big_sheet_gardna").setup({
        notify = false,                     -- Show notification for large files
        size_threshold = 1.5 * 1024 * 1024, -- Set size threshold (default: 1.5MB)
      })
    end,

  }

  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   event = { 'CursorHold', 'CursorMoved' },
  --   config = function()
  --     require("nvim-treesitter.configs").setup({
  --       textobjects = {
  --         select = {
  --           enable = true,
  --
  --           -- Automatically jump forward to textobj, similar to targets.vim
  --           lookahead = true,
  --
  --           keymaps = {
  --             -- You can use the capture groups defined in textobjects.scm
  --             ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
  --             ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
  --             ["h="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
  --             ["l="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
  --
  --             ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
  --             ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
  --             ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
  --             ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },
  --
  --             ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
  --             ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
  --
  --             ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
  --             ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
  --
  --             ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
  --             ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
  --
  --             ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
  --             ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },
  --
  --             ["am"] = {
  --               query = "@function.outer",
  --               desc = "Select outer part of a method/function definition",
  --             },
  --             ["im"] = {
  --               query = "@function.inner",
  --               desc = "Select inner part of a method/function definition",
  --             },
  --
  --             ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
  --             ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
  --           },
  --         },
  --         move = {
  --           enable = true,
  --           set_jumps = true, -- whether to set jumps in the jumplist
  --           goto_next_start = {
  --             ["]f"] = { query = "@call.outer", desc = "Next function call start" },
  --             ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
  --             ["]c"] = { query = "@class.outer", desc = "Next class start" },
  --             ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
  --             ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
  --
  --             -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
  --             -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
  --             ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
  --             ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
  --           },
  --           goto_next_end = {
  --             ["]F"] = { query = "@call.outer", desc = "Next function call end" },
  --             ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
  --             ["]C"] = { query = "@class.outer", desc = "Next class end" },
  --             ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
  --             ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
  --           },
  --           goto_previous_start = {
  --             ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
  --             ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
  --             ["[c"] = { query = "@class.outer", desc = "Prev class start" },
  --             ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
  --             ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
  --           },
  --           goto_previous_end = {
  --             ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
  --             ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
  --             ["[C"] = { query = "@class.outer", desc = "Prev class end" },
  --             ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
  --             ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },

  -- {
  --   'mei28/codelens.nvim',
  --   config = function()
  --     require('codelens').setup({})
  --   end,
  --   keys = {
  --     {
  --       "<Leader>cl",
  --       "<CMD>lua require('codelens').toggle()<CR>",
  --       { 'n', 'v' },
  --     },
  --     {
  --       '<Leader>cu',
  --       "<CMD>lua require('codelens').show_cursor_info()<CR>",
  --       { 'n', 'v' },
  --     },
  --   },
  -- },
  -- {
  --   -- 'opps-guardian.nvim',
  --   dir = '~/Documents/opps-guardian.nvim',
  --   lazy = false,
  --   init = function() require('opps-guardian').init() end,
  -- },
  -- {
  --   'mei28/swapwords.nvim',
  --   config = function()
  --     require('swapwords')
  --   end,
  --   cmd = { "SwapWord" }
  --
  -- },
  -- {
  --   'mei28/toggleqf.nvim',
  --   config = function() require('toggleqf').setup() end,
  --   keys = { '<C-g><C-o>', '<C-g><C-o>' },
  -- },
}

return spec
