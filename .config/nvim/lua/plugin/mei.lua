local spec = {
  {
    'mei28/luminate.nvim',
    event = { 'TextYankPost' },
    config = function()
      require 'luminate'.setup({
        timeout = 500,
        HIGHLIGHT_THRESHOLD = 0.5,
      })
    end
  },
}

return spec
