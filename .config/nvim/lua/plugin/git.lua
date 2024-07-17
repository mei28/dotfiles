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
      require("scrollbar.handlers.gitsigns").setup()
    end
  },
  {
    'akinsho/git-conflict.nvim',
    cmd = {
      "GitConflictChooseOurs",
      "GitConflictChooseTheirs",
      "GitConflictChooseBoth",
      "GitConflictChooseNone",
      "GitConflictNextConflict",
      "GitConflictPrevConflict",
      "GitConflictListQf",
    },
    version = '*',
    config = true
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
