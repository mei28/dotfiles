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
      behavior = cmp.ConfirmBehavior.Replace,
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
    { name = 'copilot' },
    -- { name = 'obsidian' },
    { name = 'tmux' },
    { name = 'env' },
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
cmp.event:on("menu_opened", function()
  vim.b.copilot_suggestion_hidden = true
end)

cmp.event:on("menu_closed", function()
  vim.b.copilot_suggestion_hidden = false
end)


vim.cmd [[highlight! default link CmpItemKind CmpItemMenuDefault]]
