-- Claude Code 風の `@<path>` 挿入を nvim で再現するためのモジュール。
-- 対応 filetype で insert mode 中に `@@` を連続入力すると Snacks.picker.files を開き、
-- 選択したファイルを `@<relative-path>` としてカーソル位置に挿入する。
-- 単独の `@` はそのまま通常入力される(メール・デコレータ等の誤爆防止)。
-- 検索ルートはデフォルトで現バッファの git リポジトリのトップレベル。
-- git 管理外の場合は nvim の cwd にフォールバック。

local M = {}

-- 挿入時のパス形式: "relative" (ルート基準) / "absolute"
-- 切り替え例: require("config.claude_path").format = "absolute"
M.format = "relative"

-- 検索ルートを決めるリゾルバ。上書き可能。
-- 例: require("config.claude_path").get_root = function() return "/some/dir" end
function M.get_root()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local start_dir
  if buf_name ~= "" then
    start_dir = vim.fn.fnamemodify(buf_name, ":h")
  else
    start_dir = vim.fn.getcwd()
  end
  local result = vim.fn.systemlist({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 and result[1] and result[1] ~= "" then
    return result[1]
  end
  return vim.fn.getcwd()
end

local function insert_at(bufnr, row, col, text)
  vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { text })
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  local new_col = col + #text
  if new_col >= #line then
    vim.api.nvim_win_set_cursor(0, { row, math.max(#line - 1, 0) })
    vim.cmd("startinsert!")
  else
    vim.api.nvim_win_set_cursor(0, { row, new_col })
    vim.cmd("startinsert")
  end
end

local function open_picker()
  -- snacks.nvim が lazy-load 済みでもまだ未ロードでも動くよう、明示的に require する
  local ok, picker = pcall(require, "snacks.picker")
  if not ok or not picker then
    vim.notify("snacks.picker is not available: " .. tostring(picker), vim.log.levels.WARN)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]
  local root = M.get_root()
  picker.files({
    cwd = root,
    confirm = function(p, item)
      p:close()
      if not item then
        return
      end
      local rel = item.file or item._path or item.path or item.text
      if not rel or rel == "" then
        return
      end
      local text
      if M.format == "absolute" then
        text = "@" .. vim.fn.fnamemodify((item.cwd or root) .. "/" .. rel, ":p")
      else
        text = "@" .. rel
      end
      vim.schedule(function()
        insert_at(bufnr, row, col, text)
      end)
    end,
  })
end

function M.setup_buffer(bufnr)
  bufnr = bufnr or 0
  vim.keymap.set("i", "@", function()
    local buf = vim.api.nvim_get_current_buf()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1], pos[2]
    local line = vim.api.nvim_get_current_line()
    local prev = col > 0 and line:sub(col, col) or ""

    if prev ~= "@" then
      return "@"
    end

    -- 2 回目の `@`: 直前の `@` を消してピッカーを開く
    vim.schedule(function()
      vim.api.nvim_buf_set_text(buf, row - 1, col - 1, row - 1, col, {})
      vim.api.nvim_win_set_cursor(0, { row, col - 1 })
      open_picker()
    end)
    return ""
  end, {
    buffer = bufnr,
    expr = true,
    desc = "Claude Code style @@ path picker",
  })
end

return M
