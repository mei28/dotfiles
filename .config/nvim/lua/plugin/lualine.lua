local spec = {
  {
    'nvim-lualine/lualine.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      lualine_setup()
    end,
  }
}
function lualine_setup()
  local status, lualine = pcall(require, 'lualine')
  if not status then
    return
  end

  local function lsp_names()
    ------------------------------------------------------------------
    -- A) after/lsp/*.lua → 「ファイル専用」LSP 名セットを 1 回だけ作る
    ------------------------------------------------------------------
    local function build_specific_set()
      local dir = vim.fn.stdpath('config') .. '/after/lsp'
      local uv  = vim.loop
      local h   = uv.fs_scandir(dir)
      if not h then return {} end -- ディレクトリが無い／空

      local set = {}
      while true do
        local fname, t = uv.fs_scandir_next(h)
        if not fname then break end
        if t == 'file' and fname:sub(-4) == '.lua' then
          set[fname:sub(1, -5)] = true -- pyright.lua → "pyright"
        end
      end
      return set
    end

    -- キャッシュしておく（Neovim 1 セッション中で 1 度だけ走る）
    local specific             = vim.g.__lsp_specific_cache or build_specific_set()
    vim.g.__lsp_specific_cache = specific

    ------------------------------------------------------------------
    -- B) 現在バッファにアタッチしている LSP を仕分け
    ------------------------------------------------------------------
    local specific_names       = {}
    local normal_cnt           = 0

    for _, c in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
      if specific[c.name] then
        table.insert(specific_names, c.name)
      else
        normal_cnt = normal_cnt + 1
      end
    end

    ------------------------------------------------------------------
    -- C) 表示用文字列を組み立て
    ------------------------------------------------------------------
    if #specific_names == 0 and normal_cnt == 0 then
      return " 0" -- LSP が 1 つも無い
    end

    table.sort(specific_names) -- 並び順が気になる場合だけ

    local out = { " " } -- アイコンは好みで変更可
    if #specific_names > 0 then
      table.insert(out, table.concat(specific_names, ", "))
    end
    if normal_cnt > 0 then
      table.insert(out, (" (+%d)"):format(normal_cnt))
    end

    return table.concat(out)
  end

  local function encoding()
    -- vim.bo.fileencodingを取得して、utf-8でない場合のみその値を返す
    local enc = vim.bo.fileencoding
    if enc == '' or enc:lower() == 'utf-8' then
      return ''  -- UTF-8の場合は何も表示しない
    else
      return enc -- UTF-8でない場合はエンコーディングを表示
    end
  end

  lualine.setup {
    options = {
      icons_enabled = true,
      -- section_separators = { left = '', right = '' },
      -- component_separators = { left = '', right = '' },
      section_separators = { left = ' ', right = ' ' },
      component_separators = { left = ' ', right = ' ' },
      disabled_filetypes = {}
    },
    sections = {
      lualine_a = { {
        'mode',
        fmt = function(str) return str:sub(1, 1) end,
      } },
      lualine_b = { 'diff' },
      lualine_c = {
        {
          'filename',
          path = 1,
          file_status = true,
          shorting_target = 40,
          symbols = {
            modified = '[]',
            readonly = '[]',
            unnamed = '[Untitled]',
          }
        }
      },
      lualine_x = {
        {
          'diagnostics',
          sources = { "nvim_diagnostic" },
          symbols = {
            error = ' ',
            warn = ' ',
            info = ' ',
            hint = ' '
          }
        },
      },
      -- lualine_y = { 'progress' },
      -- lualine_z = { 'location' }
      lualine_y = {
        'filetype',
        encoding,
      },
      lualine_z = {
        lsp_names
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 1            -- 0 = just filename, 1 = relative path, 2 = absolute path
      } },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    extensions = { 'fugitive' }
  }
end

return spec
