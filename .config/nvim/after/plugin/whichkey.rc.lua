local status, wk = pcall(require, 'which-key')
if not status then return end

vim.opt.timeout = true
vim.opt.timeoutlen = 300

wk.setup({})

local chatgpt = require("chatgpt")
wk.register({
  p = {
    name = "ChatGPT",
    e = {
      function()
        chatgpt.edit_with_instructions()
      end,
      "Edit with instructions",
    },
  },
}, {
  prefix = "<leader>",
  mode = "v",
})
