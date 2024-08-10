local spec = {

  -- comment
  {
    'numToStr/Comment.nvim',
    config = function() comment_setup() end,
    keys = {
      { 'gcl', 'gbc' }
    },
    event = "ModeChanged",
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' }
  },
  {
    "folke/ts-comments.nvim",
    keys = {
      { 'gcl', 'gbc' }
    },
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

}

function comment_setup()
  local status, comment = pcall(require, 'Comment')
  if not status then
    return
  end

  comment.setup(
    {
      ---LHS of toggle mappings in NORMAL mode
      ---@type table
      toggler = {
        ---Line-comment toggle keymap
        line = 'gcl',
        ---Block-comment toggle keymap
        block = 'gbc',
      },
    }
  )
end

return spec
