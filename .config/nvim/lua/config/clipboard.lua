-- OSC 52: yank を端末エスケープ経由でローカル clipboard へ直送する。
-- SSH + tmux 越しでも、リモート tmux バッファ止まりにならず手元の Mac まで届く。
-- 注意: paste はターミナルが応答しない場合が多く動かないことがある（copy が目的）。
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
