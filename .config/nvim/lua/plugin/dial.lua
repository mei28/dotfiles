-- dial
local spec =
{
  {
    'monaqa/dial.nvim',
    keys = {
      { "g<C-a>", function() require("dial.map").inc_gnormal() end, "n" },
      { "g<C-x>", function() require("dial.map").dec_gnormal() end, "n" },
      { "g<C-a>", function() require("dial.map").inc_gvisual() end, "v" },
      { "g<C-x>", function() require("dial.map").dec_gvisual() end, "v" },
    }

  }
}

return spec
