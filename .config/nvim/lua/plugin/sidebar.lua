local spec = {
  -- sidebar-nvim
  {
    'sidebar-nvim/sidebar.nvim',
    config = function()
      local status, sidebar = pcall(require, "sidebar-nvim")
      if not status then return end
      sidebar.setup({
        sections = { 'git', 'files', 'buffers', 'diagnostics', "todos" },
        files = { icon = "", show_hidden = false, ignored_paths = { "%.git$" } },
        buffers = {
          icon = "",
          ignored_buffers = {},      -- ignore buffers by regex
          sorting = "id",            -- alternatively set it to "name" to sort by buffer name instead of buf id
          show_numbers = true,       -- whether to also show the buffer numbers
          ignore_not_loaded = false, -- whether to ignore not loaded buffers
          ignore_terminal = true,    -- whether to show terminal buffers in the list
        }
      })
    end,
    keys = {
      { '<Leader>b', function() require 'sidebar-nvim'.toggle() end }
    },
  }
}
return spec
