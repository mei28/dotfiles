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
    -- branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
    },
    build = "make tiktoken",        -- Only on MacOS or Linux
    opts = {
      debug = false,                -- Enable debugging
      -- default prompts
      prompts = {
        Commit = {
          prompt =
          [[
Write a commit message following these rules:
- DO NOT include any Claude Code signatures
- Use mandatory prefix based on Angular convention:
  * feat: new feature
  * fix: bug fix
  * docs: documentation only changes
  * style: changes that don't affect code meaning (whitespace, formatting)
  * refactor: code changes that neither fix bugs nor add features
  * perf: code changes that improve performance
  * test: adding tests or modifying existing tests
  * chore: changes to build process, tools, or libraries
- Include WHY: explain the reason, background, and purpose of the change
- Focus on why the change was made, not just what was changed
- Keep title under 50 characters
- Wrap message body at 72 characters
- Format as a gitcommit code block
            ]]
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
