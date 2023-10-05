vim.g.clipboard = {
  name = 'tmux',
  copy = {
    ["+"] = { 'tmux', 'load-buffer', '-w', '-' },
    ["*"] = { 'tmux', 'load-buffer', '-w', '-' },
  },
  paste = {
    ["+"] = { 'tmux', 'save-buffer', '-' },
    ["*"] = { 'tmux', 'save-buffer', '-' },
  },
  cache_enabled = false,
}
