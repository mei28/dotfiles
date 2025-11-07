local spec = {
  {
    "lambdalisue/nvim-aibo",
    cmd = { "Claude", "VClaude", "Aibo" },
    keys = {
      {
        '<leader>ai',
        function()
          local width = math.floor(vim.o.columns * 2 / 3)
          vim.cmd(string.format('Aibo -opener="%dvsplit" claude', width))
        end,
        mode = { 'n' },
      }
    },
    config = function()
      require("aibo").setup {}

      -- Custom command for Claude with proportional window
      vim.api.nvim_create_user_command('Claude', function(opts)
        local width = math.floor(vim.o.columns * 1 / 3)
        vim.cmd(string.format('Aibo -opener="%dvsplit" claude %s', width, opts.args))
      end, { nargs = '*' })
      vim.api.nvim_create_user_command('HClaude', function(opts)
        local width = math.floor(vim.o.columns * 1 / 3)
        vim.cmd(string.format('Aibo -opener="%dsplit" claude %s', width, opts.args))
      end, { nargs = '*' })
    end

  }

}

return spec
