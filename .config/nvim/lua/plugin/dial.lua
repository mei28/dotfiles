-- dial
local spec =
{
  {
    'monaqa/dial.nvim',
    keys = {
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, "n" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, "n" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, "v" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, "v" },
    }

  }
}

return spec
