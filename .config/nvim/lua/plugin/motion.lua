local spec = {

  -- hop
  --   {
  --     'rlane/pounce.nvim',
  --     keys = {
  --       {'s', function() require 'pounce'.pounce {} end,{'n','x'}},
  --       {'S', function() require 'pounce'.pounce {do_repeat=true} end},
  --       {'gs', function() require 'pounce'.pounce {} end,{'o'}},
  --       {'S', function() require 'pounce'.pounce {input={reg='/'}} end},
  --     }
  -- },
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
