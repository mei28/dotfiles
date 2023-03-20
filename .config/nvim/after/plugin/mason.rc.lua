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
local servers = { 'pyright', 'lua_ls', 'bashls', 'html', 'clangd', 'rust_analyzer', 'quick_lint_js', 'tsserver' }

local status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not status then return end
mason_lspconfig.setup({ ensure_installed = servers })

local status, lspconfig = pcall(require, 'lspconfig')
if not status then return end

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


-- Global mappings
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'H', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Leader>lf', "<cmd>lua vim.lsp.buf.format({async=true})<CR>", bufopts)
    vim.keymap.set('n', 'cc', vim.lsp.buf.incoming_calls, bufopts)

    -- Reference highlight
    vim.cmd [[
      highlight LspReferenceText  cterm=underline ctermbg=8 gui=underline guibg=#104040
      highlight LspReferenceRead  cterm=underline ctermbg=8 gui=underline guibg=#104040
      highlight LspReferenceWrite cterm=underline ctermbg=8 gui=underline guibg=#104040
      set updatetime=100
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end
})


-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true }
)
