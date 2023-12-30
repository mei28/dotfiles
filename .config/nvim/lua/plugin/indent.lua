local spec = {
  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.opt.list = true
      vim.opt.listchars:append "space: "
      -- vim.opt.listchars:append "eol:↴"

      local status, ibl = pcall(require, 'ibl')
      if not status then
        return
      end
      ibl.setup {
        -- indent = {
        --   char = "┊",
        -- },
      }
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.opt.list = true
      vim.opt.listchars:append "space: "
      -- vim.opt.listchars:append "eol:↴"
      require("hlchunk").setup({
        line_num = {
          enable = true,
          style = "#ecc48d",
        },
        chunk = { enable = false },
        indent = { enable = false },
        blank = { enable = false }
      })
    end
  },
}

return spec
