local spec = {
  {
    "atusy/treemonkey.nvim",
    keys = {
      {
        "m",
        function() require('treemonkey').select({ ignore_injections = false }) end,
        mode = { "x", "o" }
      }
    }
  }
}

return spec
