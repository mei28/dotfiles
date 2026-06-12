-- OSC 52: send yanks straight to the local clipboard via a terminal escape.
-- Works over SSH + tmux without getting stuck in the remote tmux buffer.
-- Note: paste often fails since many terminals do not reply (copy is the goal).
local osc52 = require('vim.ui.clipboard.osc52')

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
  paste = {
    ['+'] = osc52.paste('+'),
    ['*'] = osc52.paste('*'),
  },
}
