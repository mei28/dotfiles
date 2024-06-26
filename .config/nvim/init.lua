-- load plugins.lua

require 'config.config'
require 'config.keymap'
require 'config.lazy'
require 'config.colorscheme'
require 'config.unload'

if vim.loader then vim.loader.enable() end

local has = function(x) return vim.fn.has(x) == 1 end

local is_mac = has "macunix"
local is_ubuntu = has "unix"
local is_win = has "win32"

if is_mac then require 'config.macos' end
if is_ubuntu then require 'config.macos' end
if is_win then require 'config.windows' end

-- 再読み込みコマンド
function _G.reload_module(name)
  package.loaded[name] = nil
  return require(name)
end
