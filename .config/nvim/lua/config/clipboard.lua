-- OSC 52: send yanks straight to the local clipboard via a terminal escape.
-- Works over SSH + tmux/herdr without getting stuck in the remote clipboard.
-- copy is one-way (fire-and-forget) so it works regardless of the terminal.
-- paste is intentionally NOT wired to OSC52: it requires the terminal to
-- answer a query, and WezTerm has never implemented OSC 52 read support
-- (https://github.com/wezterm/wezterm/issues/2050, open since 2022) — every
-- "+p/p (via unnamedplus) would hang until Nvim's timeout. Use the terminal's
-- native paste (e.g. Cmd+V, bracketed paste) to bring the local clipboard
-- into a remote/nested Nvim instead; that path does not go through OSC52.
--
-- Nvim still rejects a g:clipboard without `paste` ("invalid g:clipboard")
-- and then disables the clipboard entirely, so paste returns what this Nvim
-- copied last instead of querying the terminal.
local osc52 = require('vim.ui.clipboard.osc52')

-- Last copy per register, as {lines, regtype}.
local last_copied = {
  ['+'] = { { '' }, 'v' },
  ['*'] = { { '' }, 'v' },
}

local function copy(reg)
  local send = osc52.copy(reg)
  return function(lines, regtype)
    last_copied[reg] = { lines, regtype }
    send(lines)
  end
end

local function paste(reg)
  return function()
    return last_copied[reg]
  end
end

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = copy('+'),
    ['*'] = copy('*'),
  },
  paste = {
    ['+'] = paste('+'),
    ['*'] = paste('*'),
  },
}
