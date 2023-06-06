-- load plugins.lua
require 'config'
require 'keymap'
require 'plugins'
require 'colorscheme'

if vim.loader then vim.loader.enable() end

local has = function(x) return vim.fn.has(x) == 1 end

local is_mac = has "macunix"
local is_ubuntu = has "unix"
local is_win = has "win32"

if is_mac then require 'macos' end
if is_ubuntu then require 'macos' end
if is_win then require 'windows' end
