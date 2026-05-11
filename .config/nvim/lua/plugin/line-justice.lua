local spec = {
  -- {
  --   "zaakiy/line-justice.nvim",
  --   dependencies = { "luukvbaal/statuscol.nvim" },
  --   lazy = false,
  --   opts = {
  --     line_numbers = { theme = nil },
  --     wrapped_lines = { indicator = "Bar" },
  --   },
  --   config = function(_, opts)
  --     local lj = require("line-justice")
  --     local builtin = require("statuscol.builtin")
  --     lj.setup(opts)
  --
  --     require("statuscol").setup({
  --       relculright = true,
  --       segments = {
  --         { text = { builtin.foldfunc },                                                      click = "v:lua.ScFa" },
  --         { sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = true },   click = "v:lua.ScSa" },
  --         { sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true },         click = "v:lua.ScSa" },
  --         { sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true }, click = "v:lua.ScSa" },
  --         { text = { lj.segment },                                                            click = "v:lua.ScLa" },
  --       },
  --     })
  --   end,
  -- },
}

return spec
