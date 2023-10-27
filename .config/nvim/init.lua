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

-- カスタムの参照情報を表示する関数
local function show_references(_, _, result)
  if not result then
    print("No references found")
    return
  end

  -- 現在のバッファのIDを取得
  local bufnr = vim.api.nvim_get_current_buf()

  -- 既存のvirtualtextをクリア
  vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

  -- 各参照情報についてvirtualtextを設定
  for _, ref in ipairs(result) do
    if ref.uri == vim.uri_from_bufnr(bufnr) then
      local row = ref.range.start.line
      vim.api.nvim_buf_set_virtual_text(bufnr, -1, row, {{"<-- referenced", "Comment"}}, {})
    end
  end
end

-- カスタムの参照情報表示関数をLSPのcallbackとしてセット
vim.lsp.handlers["textDocument/references"] = show_references

