-- load plugins.lua

require 'config.config'
require 'config.keymap'
require 'config.lazy'
require 'config.colorscheme'
require 'config.unload'

if vim.loader then vim.loader.enable() end

local has = function(x) return vim.fn.has(x) == 1 end

-- macunix は unix の部分集合なので、判定は unix / win32 の二択でよい。
-- config.unix は clipboard=unnamedplus のみで macOS / Linux 共通。
local is_unix = has "unix"
local is_win = has "win32"

if is_unix then require 'config.unix' end
if is_win then require 'config.windows' end

-- Over SSH, route yanks to the local clipboard via OSC 52 (overrides config.unix).
-- Linux herdr panes too: they inherit the herdr server's env, so a server started
-- from the desktop hides SSH_* even when the pane is viewed over ssh. herdr hands
-- OSC 52 to the client in use (OSC 52 over ssh, xsel on the desktop).
local over_ssh = vim.env.SSH_CONNECTION or vim.env.SSH_TTY
local in_linux_herdr = vim.env.HERDR_ENV and has "linux"
if over_ssh or in_linux_herdr then
  require 'config.clipboard'
end

-- 再読み込みコマンド
function _G.reload_module(name)
  package.loaded[name] = nil
  return require(name)
end
