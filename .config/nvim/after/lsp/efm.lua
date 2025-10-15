-- efm
local ensure_installed_linter_formatter = {
  'eslint',
  'prettier',
  'stylua',
  -- 'black',
  'mypy',
  -- 'isort',
  -- 'flake8',
  'ruff',
  'yamllint',
  'shellcheck',
  'stylelint',
  'beautysh'
}

local status, mti                       = pcall(require, 'mason-tool-installer')
mti.setup({ ensure_installed = ensure_installed_linter_formatter })
-- Register linters and formatters per language
local prettier   = require('efmls-configs.formatters.prettier')
local eslint     = require('efmls-configs.linters.eslint')

-- local black      = require('efmls-configs.formatters.black')
-- local mypy       = require('efmls-configs.linters.mypy')
-- local isort      = require('efmls-configs.formatters.isort')
-- local flake8     = require('efmls-configs.linters.flake8')
local ruff_f     = require('efmls-configs.formatters.ruff')
local ruff_l     = require('efmls-configs.linters.ruff')

local yamllint   = require('efmls-configs.linters.yamllint')

local shellcheck = require('efmls-configs.linters.shellcheck')
local beautysh   = require('efmls-configs.formatters.beautysh')

local stylelint  = require('efmls-configs.linters.stylelint')

local statix     = require('efmls-configs.linters.statix')
local alejandra  = require('efmls-configs.formatters.alejandra')
local nixfmt     = require('efmls-configs.formatters.nixfmt')


local languages    = {
  python = { --[[ mypy, ]] ruff_f, ruff_l, },
  yaml = { yamllint, prettier, },
  json = { prettier, },
  svelte = { eslint, prettier, },
  sh = { shellcheck, beautysh, },
  lua = {},
  css = { stylelint, prettier },
  nix = { statix, alejandra, nixfmt },
}
local efmls_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
}

return {
  vim.tbl_extend('force', efmls_config, {})
}
