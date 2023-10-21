local spec = {

  -- comment
  {
    'numToStr/Comment.nvim',
    config = function() comment_setup() end,
    keys = {
      { 'gcl' }
    },
    event = "ModeChanged",
  }

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
