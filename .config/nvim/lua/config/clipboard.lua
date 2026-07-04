-- OSC 52: send yanks straight to the local clipboard via a terminal escape.
-- Works over SSH + tmux without getting stuck in the remote tmux buffer.
-- copy is one-way (fire-and-forget) so it works regardless of the terminal.
-- paste is intentionally NOT wired to OSC52: it requires the terminal to
-- answer a query, and WezTerm has never implemented OSC 52 read support
-- (https://github.com/wezterm/wezterm/issues/2050, open since 2022) — every
-- "+p/p (via unnamedplus) would hang until Nvim's timeout. Use the terminal's
-- native paste (e.g. Cmd+V, bracketed paste) to bring the local clipboard
-- into a remote/nested Nvim instead; that path does not go through OSC52.
local osc52 = require('vim.ui.clipboard.osc52')

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
}
