local spec = {
  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup({
        preview_window = {
          auto_preview = true,
          open_hover_on_preview = true,
        },
        outline_window = {
          position = 'right',
          auto_close = true,
          show_numbers = true,
        },
        outline_items = {
          show_symbol_details = true,
        },
        symbols = {
          icons = { icon_source = 'lspkind' },
        }
      });
    end,
    keys = {
      { ';a', '<CMD>Outline<CR>', desc = "Toggle outline" },
    },
  }
}

return spec
