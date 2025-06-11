local spec = {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end,
    kyes = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
    },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume" },
  }
}

return spec
