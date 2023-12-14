local spec = {

  --- cmp
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    config = function() cmp_setup() end
  },
  { 'hrsh7th/cmp-nvim-lsp',                event = 'InsertEnter' },
  { 'hrsh7th/cmp-buffer',                  event = 'InsertEnter' },
  { 'hrsh7th/cmp-path',                    event = 'InsertEnter' },
  { 'hrsh7th/cmp-nvim-lsp-signature-help', event = 'InsertEnter' },
  { 'yutkat/cmp-mocword',                  event = 'InsertEnter' },
  { 'hrsh7th/cmp-cmdline',                 event = 'ModeChanged' },
  { 'ray-x/cmp-treesitter',                event = 'InsertEnter' },
  { 'saadparwaiz1/cmp_luasnip',            event = 'InsertEnter' },
  { 'andersevenrud/cmp-tmux',              event = 'InsertEnter' },
  { 'bydlw98/cmp-env',                     event = 'InsertEnter' },
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    event = 'LspAttach',
    config = function()
      require 'fidget'.setup({})
    end
  },
  {
    'onsails/lspkind-nvim', -- vscode-like pictograms
    config = function() lspkind_setup() end,

  },
  {
    "L3MON4D3/LuaSnip",
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = function() luasnip_setup() end,
    keys = {
      { "<C-m>", "<Plug>luasnip-next-choice", { "i", "s" } },
      { "<C-k>", "<Plug>luasnip-prev-choice", { 'i', 's' } }
    }
  },

}

function cmp_setup()
  local status, cmp = pcall(require, "cmp")
  if (not status) then return end
  local lspkind = require 'lspkind'
  local luasnip = require 'luasnip'

  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
  end
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      -- ['<C-l>'] = cmp.mapping.complete(),
      ["<C-l>"] = cmp.mapping {
        i = function(fallback)
          if luasnip.choice_active() then
            luasnip.change_choice(1)
          else
            fallback()
          end
        end,
      },
      ['<Esc>'] = cmp.mapping.close(),
      ['<C-{>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({
        select = true,
        behavior = cmp.ConfirmBehavior.Insert,
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = 'luasnip',                option = { show_autosnippets = true } },
      { name = 'buffer' },
      { name = "mocword" },
      { name = 'nvim_lsp' },
      { name = "path" },
      { name = "nvim_lsp_signature_help" },
      { name = "treesitter" },
      -- { name = 'obsidian' },
      { name = 'tmux' },
      { name = 'env' },
      -- { name = 'copilot',                priority = -50 },
    }),
    formatting = {
      format = lspkind.cmp_format({ with_text = false, maxwidth = 50 })
    },
  })

  -- `:` cmdline setup.
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' }
        }
      }
    })
  })

  -- `/` and `?` cmdline setup.
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- for copilot
  -- cmp.event:on("menu_opened", function()
  --   vim.b.copilot_suggestion_hidden = true
  -- end)
  --
  -- cmp.event:on("menu_closed", function()
  --   vim.b.copilot_suggestion_hidden = false
  -- end)

  -- for cmp + autopairs: https://github.com/windwp/nvim-autopairs#mapping-cr
  -- and it needs to come after lsp-zero is configured: https://github.com/VonHeikemen/lsp-zero.nvim/discussions/119
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
  )


  vim.cmd [[highlight! default link CmpItemKind CmpItemMenuDefault]]
end

function lspkind_setup()
  local status, lspkind = pcall(require, "lspkind")
  if (not status) then return end

  lspkind.init({
    -- enables text annotations
    --
    -- default: true
    mode = 'symbol',

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "",
      Copilot = "",
    },
  })
end

function luasnip_setup()
  local status, ls = pcall(require, "luasnip")
  if not status then
    return
  end
  local s = ls.snippet
  local sn = ls.snippet_node
  local isn = ls.indent_snippet_node
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node
  local c = ls.choice_node
  local d = ls.dynamic_node
  local r = ls.restore_node
  local events = require("luasnip.util.events")
  local ai = require("luasnip.nodes.absolute_indexer")
  local extras = require("luasnip.extras")
  local l = extras.lambda
  local rep = extras.rep
  local p = extras.partial
  local m = extras.match
  local n = extras.nonempty
  local dl = extras.dynamic_lambda
  local fmt = require("luasnip.extras.fmt").fmt
  local fmta = require("luasnip.extras.fmt").fmta
  local conds = require("luasnip.extras.expand_conditions")
  local postfix = require("luasnip.extras.postfix").postfix
  local types = require("luasnip.util.types")
  local parse = require("luasnip.util.parser").parse_snippet
  local ms = ls.multi_snippet
  local k = require("luasnip.nodes.key_indexer").new_key

  ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    store_selection_keys = "<C-q>",
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { "●", "GruvboxOrange" } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { "●", "GruvboxBlue" } },
        },
      },
    }
  }


  local function today(n)
    if n == 1 then
      return os.date('%Y-%m-%d')
    elseif n == 2 then
      return os.date('%Y/%m/%d')
    elseif n == 3 then
      return os.date('%Y%m%d')
    else
      return os.date('%Y-%m-%d')
    end
  end


  ls.add_snippets(
    'all', {
      s('@Today', c(1, { t(today(1)), t(today(2)), t(today(3)) })),
      s('TSU', { t('TSUNDOKU') }),
      s('HCO', { t('HCOMP') }),
    }
  )

  ls.add_snippets(
    'python', {
      s('ipd', {
        t("from ipdb import set_trace as ist")
      }),
      s('pdb', {
        t("from pdb import set_trace as ist")
      }),
    }
  )

  -- set keybinds for both INSERT and VISUAL.
  local set = vim.keymap.set
  set({ "i", "s" }, "<C-m>", "<Plug>luasnip-next-choice")
  set({ 'i', 's' }, "<C-k>", "<Plug>luasnip-prev-choice")

  -- to fix bugs -> maparg('<CR>', 'n', 0, 1)
  -- { buffer = 0, expr = 0, lhs = "<CR>", lhsraw = "\r",
  -- lnum = 0, mode = "n", noremap = 1, nowait = 0,
  -- rhs = "<Plug>luasnip-next-choice", script = 0, sid = -8, silent = 0 }
  vim.keymap.del('n', '<CR>')
end

return spec
