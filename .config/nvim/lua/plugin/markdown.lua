--   -- markdown
local spec = {
  -- {
  --   'iamcco/markdown-preview.nvim',
  --   build = 'cd app && npm install',
  --   init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  --   ft = { 'markdown', 'text' }
  -- },
  {
    'toppair/peek.nvim',
    build = 'deno task --quiet build:fast',
    ft = { 'markdown', 'text' },
    config = function() peek_setup() end,
    cmd = { "Peek" }
  },
  -- table markdonw
  {
    'dhruvasagar/vim-table-mode',
    ft = { 'markdown', 'text' },
    cmd = { 'TableModeToggle', 'TableModeEnable', 'TableModeDisable', 'Tableize', 'TableModeRealign' },
  },
  {
    'mattn/vim-maketable',
    ft = { 'markdown', 'text' },
    event = "ModeChanged",
    cmd = { "MakeTable" }
  },
  {
    'richardbizik/nvim-toc',
    ft = { 'markdown', 'text' },
    config = function()
      require('nvim-toc').setup()
    end,
    cmd = { "TOC" }
  },
}


function peek_setup()
  local status, peek = pcall(require, 'peek')
  if not status then
    return
  end
  vim.api.nvim_create_user_command('PeekOpen', peek.open, {})
  vim.api.nvim_create_user_command('PeekClose', peek.close, {})
  vim.api.nvim_create_user_command('Peek', function() if peek.is_open() then peek.close() else peek.open() end end, {})
  -- default config:
  peek.setup({
    auto_load = true,        -- whether to automatically load preview when
    -- entering another markdown buffer
    close_on_bdelete = true, -- close preview window on buffer delete

    syntax = true,           -- enable syntax highlighting, affects performance

    theme = 'dark',          -- 'dark' or 'light'

    update_on_change = true,

    app = 'browser', -- 'webview', 'browser', string or a table of strings
    -- explained below

    filetype = { 'markdown' }, -- list of filetypes to recognize as markdown

    -- relevant if update_on_change is true
    throttle_at = 200000,   -- start throttling when file exceeds this
    -- amount of bytes in size
    throttle_time = 'auto', -- minimum amount of time in milliseconds
    -- that has to pass before starting new render
  })
end

return spec
