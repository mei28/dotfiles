local spec = {
  {
    'folke/todo-comments.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function() require 'todo-comments'.setup() end
  },
}

return spec
