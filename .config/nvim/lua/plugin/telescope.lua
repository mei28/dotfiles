local spec = {

  {
    'nvim-telescope/telescope.nvim',
    config = function() telescope_setup() end,
    keys = {
      { ';f', function() require("telescope.builtin").find_files({ hidden = true, initial_mode = "normal", }) end },
      { ';b', function() require("telescope.builtin").buffers() end },
      { ';t', function() require("telescope.builtin").help_tags() end },
      { ';q', function() require("telescope.builtin").quickfix() end },
      -- set('n', ';;', function() builtin.resume() end)
      { ';e', function() require("telescope.builtin").diagnostics() end },
      { ";s", function()
        require("telescope").extensions.file_browser.file_browser({
          path = "%:p:h",
          cwd = vim.fn.expand('%:p:h'),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 }
        })
      end },
      { ';k', function() require("telescope.builtin").keymaps() end },
    },
    dependencies = {
      { 'nvim-telescope/telescope-file-browser.nvim', },
      { 'nvim-telescope/telescope-ui-select.nvim', },
      { "nvim-telescope/telescope-dap.nvim", }
    }
  },
}

function telescope_setup()
  local status, telescope = pcall(require, "telescope")
  if not status then return end

  local actions = require('telescope.actions')
  -- local builtin = require("telescope.builtin")
  --
  -- local function telescope_buffer_dir() return vim.fn.expand('%:p:h') end

  local fb_actions = require "telescope".extensions.file_browser.actions

  telescope.setup {
    defaults = { mappings = { n = { ["q"] = actions.close } } },
    extensions = {
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
        initial_mode = "normal",
        mappings = {
          -- your custom insert mode mappings
          ["i"] = { ["<C-w>"] = function()
            vim.cmd('normal vbd')
          end },
          ["n"] = {
            -- your custom normal mode mappings
            ["N"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["/"] = function() vim.cmd('startinsert') end
          }
        }
      },
      ['ui-select'] = {
        require('telescope.themes').get_dropdown {}
      }
    }
  }

  telescope.load_extension("file_browser")
  telescope.load_extension("ui-select")
  telescope.load_extension("dap")
end

return spec
