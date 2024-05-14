local spec = {
  {
    'williamboman/mason.nvim',
    event = { 'CursorMoved', 'CursorHold' },
    config = function()
      mason_setup()
      vim.cmd "LspStart"
    end
  },
  { 'williamboman/mason-lspconfig.nvim',         cmd = { 'LspInstall', 'LspUninstall' } },
  { "neovim/nvim-lspconfig",                     cmd = { 'LspInfo' } },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim', cmd = { 'MasonToolsUpdate' } }
}

function mason_setup()
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
  local servers = {
    'lua_ls',
    'bashls',
    'html',
    'clangd',
    'rust_analyzer',
    'quick_lint_js',
    'tsserver',
    'jsonls',
    'efm',
    'pyright',
    'svelte',
    'tailwindcss',
    'emmet_ls',
  }

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

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  local status, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if not status then
    print('cmp_nvim_lsp not found')
    return
  end
  local capabilities = cmp_nvim_lsp.default_capabilities()
  for _, lsp in ipairs(servers) do
    if lsp == 'rust_analyzer' then
      goto continue
    end
    lspconfig[lsp].setup({ capabilities = capabilities })
    ::continue::
  end

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


  capabilities.offsetEncoding = { "utf-16" }
  lspconfig.clangd.setup({ capabilities = capabilities })

  lspconfig.rust_analyzer.setup {
    filetypes = { "rust" },
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
    settings = {
      ['rust_analyzer'] = {
        cargo = {
          allFeatures = true,
        },
        -- enable clippy on save
        check = {
          command = "clippy",
        },
      }
    }
  }

  lspconfig.mojo.setup({})

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
      set('n', '<Leader>lf', "<CMD>lua vim.lsp.buf.format({async=true})<CR>", bufopts)
      set('n', 'cc', vim.lsp.buf.incoming_calls, bufopts)

      local client = vim.lsp.get_active_clients()[1]
      if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, ev.buf)
      end

      -- inlay hint
      local bufnr = ev.buf
      local supports_inlay_hints = client and client.server_capabilities.inlayHintProvider
      vim.g.inlay_hints_enabled = false
      if supports_inlay_hints then
        vim.lsp.inlay_hint.enable(false, { bufnr })
        -- Inlay Hintsの表示状態をトグルするコマンド
        vim.api.nvim_create_user_command(
          'ToggleInlayHint',
          function()
            vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
            if vim.g.inlay_hints_enabled then
              vim.lsp.inlay_hint.enable(true, { bufnr })
            else
              vim.lsp.inlay_hint.enable(false, { bufnr })
            end
          end,
          { desc = 'Toggle Inlay Hints' }
        )

        -- Inlay Hintsを有効にするコマンド
        vim.api.nvim_create_user_command(
          'EnableInlayHint',
          function()
            vim.g.inlay_hints_enabled = true
            vim.lsp.inlay_hint.enable(true, { bufnr })
          end,
          { desc = 'Enable Inlay Hints' }
        )

        -- Inlay Hintsを無効にするコマンド
        vim.api.nvim_create_user_command(
          'DisableInlayHint',
          function()
            vim.g.inlay_hints_enabled = false
            vim.lsp.inlay_hint.enable(false, { bufnr })
          end,
          { desc = 'Disable Inlay Hints' }
        )

        -- InsertEnterとInsertLeaveの自動コマンドを作成
        vim.api.nvim_create_autocmd("InsertEnter", {
          callback = function()
            if vim.g.inlay_hints_enabled then
              vim.lsp.inlay_hint.enable(false, { bufnr })
            end
          end,
          buffer = bufnr,
        })
        vim.api.nvim_create_autocmd("InsertLeave", {
          callback = function()
            if vim.g.inlay_hints_enabled then
              vim.lsp.inlay_hint.enable(true, { bufnr })
            end
          end,
          buffer = bufnr,
        })
      end
    end
  })


  -- LSP handlers, virtualtext
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true }
  )
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      vim.diagnostic.hide(nil, vim.api.nvim_get_current_buf())
    end
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      vim.diagnostic.show(nil, vim.api.nvim_get_current_buf())
    end
  })

  -- https://zenn.dev/vim_jp/articles/c62b397647e3c9 エラー警告ヒントの順番を固定
  vim.diagnostic.config({ severity_sort = true })



  -- efm
  local ensure_installed_linter_formatter = {
    'eslint_d',
    'prettier',
    'stylua',
    -- 'black',
    'mypy',
    -- 'isort',
    -- 'flake8',
    'ruff',
    'yamllint',
    'shellcheck',
    'beautysh'
  }

  local status, mti                       = pcall(require, 'mason-tool-installer')
  mti.setup({ ensure_installed = ensure_installed_linter_formatter })
  -- Register linters and formatters per language
  local prettier   = require('efmls-configs.formatters.prettier')
  local eslint     = require('efmls-configs.linters.eslint')

  -- local black      = require('efmls-configs.formatters.black')
  local mypy       = require('efmls-configs.linters.mypy')
  -- local isort      = require('efmls-configs.formatters.isort')
  -- local flake8     = require('efmls-configs.linters.flake8')
  local ruff_f     = require('efmls-configs.formatters.ruff')
  local ruff_l     = require('efmls-configs.linters.ruff')

  local yamllint   = require('efmls-configs.linters.yamllint')

  local shellcheck = require('efmls-configs.linters.shellcheck')
  local beautysh   = require('efmls-configs.formatters.beautysh')

  local cspell     = require('efmls-configs.linters.cspell')


  local languages    = {
    python = { mypy, ruff_f, ruff_l, cspell },
    yaml = { yamllint, prettier, cspell },
    json = { prettier, cspell },
    svelte = { eslint, prettier, cspell },
    sh = { shellcheck, beautysh, cspell },
    lua = { cspell }
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
  ::continue::
end

return spec
