local spec = {
  {
    "folke/flash.nvim",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
      },
      {
        "s",
        mode = { "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
    },
  },
}

return spec
