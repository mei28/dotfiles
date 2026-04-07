-- copilot (native LSP + vim.lsp.inline_completion)

--- insert_text から可視部分（カーソル以降）の最初の word だけを残す
---@param item vim.lsp.inline_completion.Item
---@return vim.lsp.inline_completion.Item?
local function accept_word(item)
  local text = type(item.insert_text) == 'string' and item.insert_text or item.insert_text.value

  -- range がある場合、range start〜cursor が既入力分
  local prefix_len = 0
  if item.range then
    local _, start_col = item.range:to_extmark()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
    prefix_len = math.max(0, cursor_col - start_col)
  end

  local remaining = text:sub(prefix_len + 1)
  -- Vim 的な word: [%w_]+ または非 word 非空白の連続
  local word = remaining:match('^([%w_]+)') or remaining:match('^([^%w_%s]+)')
  if word then
    item.insert_text = text:sub(1, prefix_len) .. word
    return item
  end
end

--- insert_text の最初の行だけを残す
---@param item vim.lsp.inline_completion.Item
---@return vim.lsp.inline_completion.Item?
local function accept_line(item)
  local text = type(item.insert_text) == 'string' and item.insert_text or item.insert_text.value
  local line = text:match('^([^\n]+)')
  if line then
    item.insert_text = line
    return item
  end
end

local spec = {
  {
    'zbirenbaum/copilot.lua',
    -- CopilotChat の認証用に残す（suggestion/panel は無効化）
    lazy = true,
    init = function()
      vim.lsp.enable('copilot')
      vim.lsp.inline_completion.enable()

      -- バッファローカルのキーマップを LspAttach で設定
      -- → nvim-cmp のグローバルマッピングより優先される
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= 'copilot' then return end

          vim.keymap.set('i', '<C-c>', function()
            if not vim.lsp.inline_completion.get() then
              return '<C-c>'
            end
          end, { buffer = ev.buf, expr = true, desc = 'Accept inline completion' })

          vim.keymap.set('i', '<C-w>', function()
            if not vim.lsp.inline_completion.get({ on_accept = accept_word }) then
              return '<C-w>'
            end
          end, { buffer = ev.buf, expr = true, desc = 'Accept inline completion (word)' })

          vim.keymap.set('i', '<C-l>', function()
            if not vim.lsp.inline_completion.get({ on_accept = accept_line }) then
              return '<C-l>'
            end
          end, { buffer = ev.buf, expr = true, desc = 'Accept inline completion (line)' })
        end,
      })
    end,
    config = function()
      local ok, copilot = pcall(require, 'copilot')
      if not ok then return end

      copilot.setup({
        panel = { enabled = false },
        suggestion = { enabled = false },
      })
    end,
    cmd = 'Copilot',
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      debug = false,
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
