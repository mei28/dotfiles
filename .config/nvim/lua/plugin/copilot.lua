-- copilot

local spec = {
  {
    'zbirenbaum/copilot.lua',
    event = { 'InsertEnter' },
    config = function()
      local status, copilot = pcall(require, 'copilot')
      if not status then return end
      -- local status, cop_cmp = pcall(require, 'copilot_cmp')
      -- if not status then return end

      copilot.setup({
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-c>",
            accept_word = "<C-w>",
            accept_line = "<C-l>",
          },
        },
        filetypes = { markdown = true, gitcommit = true, },
      })
      -- cop_cmp.setup({})
    end,
    cmd = 'Copilot'
  },
  -- {
  --   'zbirenbaum/copilot-cmp',
  --   event = { 'InsertEnter' },
  --   dependencies = { 'copilot.lua' },
  -- },
  {

    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
    },
    opts = {
      debug = false, -- Enable debugging
      -- default prompts
      prompts = {
        CommitStaged = {
          prompt =
          'Write a commit message following the commitizen convention. The title should be a concise summary of the change, with a maximum of 50 characters. The message should include a detailed description of what was changed and why, wrapped at 72 characters per line. Wrap the whole message in a code block with language gitcommit. Ensure the message is clear and informative for future reference.',
        },
      },
    },
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatDebugInfo",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatFixDiagnostic",
      "CopilotChatCommit",
      "CopilotChatCommitStaged",
      "CopilotChatModels"
    }
  },
}




return spec
