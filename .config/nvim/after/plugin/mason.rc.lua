---@diagnostic disable: redefined-local
local status, mason = pcall(require, 'mason')
if not status then return end

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- add lsp
local servers = { 'lua_ls', 'bashls', 'html', 'clangd', 'rust_analyzer', 'quick_lint_js', 'tsserver',
  'jsonls', 'efm', 'pyright' }

local status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not status then return end
mason_lspconfig.setup({ ensure_installed = servers })

local status, lspconfig = pcall(require, 'lspconfig')
if not status then return end

local status, navic = pcall(require, 'nvim-navic')
if not status then return end

-- https://github.com/neovim/neovim/issues/23291#issuecomment-1523243069
-- https://github.com/neovim/neovim/pull/23500#issuecomment-1585986913
-- pyright asks for every file in every directory to be watched,
-- so for large projects that will necessarily turn into a lot of polling handles being created.
-- sigh
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  wf._watchfunc = function()
    return function() end
  end
end

for _, lsp in ipairs(servers) do lspconfig[lsp].setup({}) end

-- settings for specific LSP
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'hs', 'wez' }
      }
    }
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.offsetEncoding = { "utf-16" }
lspconfig.clangd.setup({ capabilities = capabilities })

lspconfig.rust_analyzer.setup {
  filetypes = { "rust" },
  root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
  settings = {
    ['rust_analyzer'] = {
      cargo = {
        allFeatures = true,
      }
    }
  }
}


-- Global mappings
local set = vim.keymap.set
set('n', '[d', vim.diagnostic.goto_prev)
set('n', ']d', vim.diagnostic.goto_next)
set('n', '<Leader>e', vim.diagnostic.open_float)
set('n', '<Leader>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local bufopts = { buffer = ev.buf }
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    set('n', 'gd', vim.lsp.buf.definition, bufopts)
    set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    set('n', 'gr', vim.lsp.buf.references, bufopts)
    set('n', 'H', vim.lsp.buf.hover, bufopts)
    set('n', 'K', vim.lsp.buf.signature_help, bufopts)
    set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
    set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
    set('n', '<Leader>lf', "<cmd>lua vim.lsp.buf.format({async=true})<CR>", bufopts)
    set('n', 'cc', vim.lsp.buf.incoming_calls, bufopts)

    -- Reference highlight
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_command("highlight LspReferenceText  cterm=underline ctermbg=8 gui=underline guibg=#104040")
      vim.api.nvim_command("highlight LspReferenceRead  cterm=underline ctermbg=8 gui=underline guibg=#104040")
      vim.api.nvim_command("highlight LspReferenceWrite cterm=underline ctermbg=8 gui=underline guibg=#104040")
      vim.api.nvim_command("set updatetime=100")
      vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
      vim.api.nvim_clear_autocmds { buffer = ev.buf, group = "lsp_document_highlight" }
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = vim.lsp.buf.document_highlight,
        buffer = ev.buf,
        group = "lsp_document_highlight",
        desc = "Document Highlight",
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.lsp.buf.clear_references(bufnr)
        end,
        buffer = ev.buf,
        group = "lsp_document_highlight",
        desc = "Clear All the References",
      })
    end

    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, ev.buf)
    end
  end
})


-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true }
)


-- efm
ensure_installed_linter_formatter = {
  'eslint',
  'prettier',
  'stylua',
  'black',
  'mypy',
  'isort',
  'flake8'
}

local status, mti                 = pcall(require, 'mason-tool-installer')
mti.setup({ ensure_installed = ensure_installed_linter_formatter })
-- Register linters and formatters per language
local eslint   = require('efmls-configs.linters.eslint')
local prettier = require('efmls-configs.formatters.prettier')
local stylua   = require('efmls-configs.formatters.stylua')

local black    = require('efmls-configs.formatters.black')
local mypy     = require('efmls-configs.linters.mypy')
local isort    = require('efmls-configs.formatters.isort')
local flake8   = require('efmls-configs.linters.flake8')

local yamllint = require('efmls-configs.linters.yamllint')


local languages    = {
  typescript = { eslint, prettier },
  python = { black, mypy, isort, flake8 },
  yaml = { yamllint, prettier },
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
lspconfig.efm.setup(vim.tbl_extend('force', efmls_config, {
}))
