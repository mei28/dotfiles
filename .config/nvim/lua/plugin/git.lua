local spec = {

  -- -- git
  {
    'dinhhuy258/git.nvim',
    keys = {
      { "<Leader>gb", desc = "Git: git blame" },
      { "<Leader>go", desc = "Git: go github" }
    },
    config = function()
      local status, git = pcall(require, "git")
      if (not status) then return end
      git.setup({
        keymaps = {
          -- Open blame window
          blame = "<Leader>gb",
          -- Open file/folder in git repository
          browse = "<Leader>go",
        }
      })
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      require 'gitsigns'.setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '│' },
          delete       = { text = '-' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
      })
      -- require("scrollbar.handlers.gitsigns").setup()
    end
  },
  {
    'Tronikelis/conflict-marker.nvim',
    config = function()
      require("conflict-marker").setup({
        highlights = true,
        on_attach = function(conflict)
          local MID = "^=======$"

          vim.keymap.set("n", "[x", function()
            vim.cmd("?" .. MID)
          end, { buffer = conflict.bufnr })

          vim.keymap.set("n", "]x", function()
            vim.cmd("/" .. MID)
          end, { buffer = conflict.bufnr })

          local map = function(key, fn)
            vim.keymap.set("n", key, fn, { buffer = conflict.bufnr })
          end

          -- or you can map these to <cmd>ChooseOurs<cr>

          map("co", function()
            conflict:choose_ours()
          end)
          map("ct", function()
            conflict:choose_theirs()
          end)
          map("cb", function()
            conflict:choose_both()
          end)
          map("cn", function()
            conflict:choose_none()
          end)
        end,
      })
    end,
    cmd = {
      'ConflictOurs',
      'ConflictTheirs',
      'ConflictBoth',
      'ConflictNone',
    }

  },
  {
    'sindrets/diffview.nvim',
    cmd = {
      "DiffviewFileHistory",
      "DiffviewOpen",
      "DiffviewClose",
    },
  },
  { 'rhysd/git-messenger.vim', cmd = { 'GitMessenger' } },
  {
    'niuiic/git-log.nvim',
    dependencies = { 'niuiic/core.nvim' },
    keys = {
      {
        "gL",
        function()
          require("git-log").check_log()
        end,
        mode = { "v", "n" },
        desc = "Git: show log",
      },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup()
    end,
    cmd = { "BlameToggle" }
  }
}


return spec
