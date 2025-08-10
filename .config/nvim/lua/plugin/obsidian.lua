local spec = {

  {
    'epwalsh/obsidian.nvim',
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      -- see below for full list of optional dependencies 👇
      "telescope.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      vim.opt.conceallevel = 0
      local status, obsidian = pcall(require, 'obsidian')
      if not status then return end

      obsidian.setup({
        dir = '~/Documents/ovault/',
        completion = {
          nvim_cmp = true,
        },
        daily_notes = { folder = 'vault' },
        ui = { enable = false },
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
      {
        'Leader>gf',
        function()
          if require("obsidian").util.cursor_on_markdown_link() then
            return "<CMD>ObsidianFollowLink<CR>"
          else
            print("Cursor is not on a markdown link")
          end
        end,
        desc = "ObsidianFollowLink",
        { noremap = false, expr = true }
      },
      { '<Leader>ot', '<CMD>ObsidianToday<CR>' }
    },
    ft = { 'markdown' }
  },
}

return spec
