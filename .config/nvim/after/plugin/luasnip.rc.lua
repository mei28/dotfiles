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
    s('@Today', c(1, { t(today(1)), t(today(2)), t(today(3)) })) }
)

ls.add_snippets(
  'python', {
    s('ipd', {
      t("from ipdb import set_trace as ist")
    }),
  }
)

-- set keybinds for both INSERT and VISUAL.
local set = vim.keymap.set
set({ "i", "s" }, "<C-e>", "<Plug>luasnip-next-choice")
-- set({ "i", "s" }, "<C-p>", "<Plug>luasnip-prev-choice")
