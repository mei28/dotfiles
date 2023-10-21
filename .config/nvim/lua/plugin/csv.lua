local spec = {
  {
    'Decodetalkers/csv-tools.lua',
    ft = 'csv',
    config = function()
      local status, csvtools = pcall(require, 'csvtools')
      if not status then
        return
      end

      csvtools.setup({
        before = 10,
        after = 10,
        clearafter = true,
        -- this will clear the highlight of buf after move
        showoverflow = false,
        -- this will provide a overflow show
        titelflow = true,
        -- add an alone title
      })
    end
  },
  {
    'vidocqh/data-viewer.nvim',
    opts = {
      view = {
        width = 0.95,  -- Less than 1 means ratio to screen width
        height = 0.95, -- Less than 1 means ratio to screen height
        zindex = 50,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kkharji/sqlite.lua", -- Optional, sqlite support
    },
    ft = { 'csv', 'tsv' },
    cmd = { 'DataViewer' }
  },

}

return spec
