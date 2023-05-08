local status, telescope = pcall(require, "telescope")
if not status then return end

local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

local function telescope_buffer_dir() return vim.fn.expand('%:p:h') end
local set = vim.keymap.set

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

set('n', ';f', function()
  builtin.find_files({
    hidden = true,
    initial_mode = "normal",
  })
end)
set('n', ';r', function() builtin.live_grep() end)
set('n', ';b', function() builtin.buffers() end)
set('n', ';t', function() builtin.help_tags() end)
-- set('n', ';;', function()
--   builtin.resume()
-- end)
set('n', ';e', function() builtin.diagnostics() end)
set("n", "fs", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 }
  })
end)

set('n', ';k', function() builtin.keymaps() end)
