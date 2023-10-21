local spec = {

  {
    'epwalsh/obsidian.nvim',
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      -- see below for full list of optional dependencies 👇
    },
    config = function()
      local status, obsidian = pcall(require, 'obsidian')
      if not status then return end
      local set = vim.keymap.set

      obsidian.setup({
        dir = '~/Documents/ovault/',
        completion = {
          nvim_cmp = true,
        },
        daily_notes = { folder = 'vault' },
        note_id_func = function(title)
          -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
          local suffix = ""
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          -- return tostring(os.time()) .. "-" .. suffix
          return suffix
        end
      })
    end,
    keys = {
      { 'gf',
        function()
          if require 'obsidian'.util.cursor_on_markdown_link() then
            return "<cmd>ObsidianFollowLink<CR>"
          else
            return "gf"
          end
        end,
        { 'n' },
        { noremap = false, expr = true }
      },
      { '<Leader>ot', ':ObsidianToday<CR>' }
    },
    ft = { 'markdown' }
  },
}

return spec
