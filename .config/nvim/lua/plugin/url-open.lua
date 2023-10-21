local spec = {
  -- url open
  {
    "sontungexpt/url-open",
    cmd = "URLOpenUnderCursor",
    config = function()
      require "url-open".setup({})
    end,
    keys = {
      { "gx", "<esc>:URLOpenUnderCursor<cr>" }
    }
  },
}

return spec
