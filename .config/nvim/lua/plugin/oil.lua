local spec = {

  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup({
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
          ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["q"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
      })
    end,
    cmd = { 'Oil' },
    keys = {
      { '-', '<CMD>Oil<CR>', 'n' }
    }
  },

  {
    'Tronikelis/xylene.nvim',
    config = function()
      require("xylene").setup({
        icons = {
          files = true,
          dir_open = "  ",
          dir_close = "  ",
        },
        keymaps = {
          enter = "<cr>",
        },
        indent = 4,
        sort_names = function(a, b)
          return a.name < b.name
        end,
        skip = function(name, filetype)
          return name == ".git"
        end,
        on_attach = function(renderer)
          vim.keymap.set("n", "<c-cr>", function()
            local row = vim.api.nvim_win_get_cursor(0)[1]

            local file = renderer:find_file(row)
            if not file then
              return
            end

            require("oil").open(file.path)
          end, { buffer = renderer.buf })
        end,
      })
    end,
    cmd = { 'Xylene' }
  }
}

return spec
