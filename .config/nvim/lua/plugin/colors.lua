local spec = {
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      vim.opt.termguicolors = true
      require('nvim-highlight-colors').setup {
        enable_tailwind = true,
        render = 'virtual',
        virtual_symbol_prefix = '[',
        virtual_symbol_suffix = ']',
        virtual_symbol_position = 'eol',
      }
    end

  },
  {
    'uga-rosa/ccc.nvim',
    config = function()
      -- Enable true color
      vim.opt.termguicolors = true
      local status, ccc = pcall(require, "ccc")
      if not status then return end
      local mapping = ccc.mapping

      ccc.setup({
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
      })
    end,
    cmd = { 'CccPick' },
  },
  {
    'fei6409/log-highlight.nvim',
    ft = { 'log' },
    config = function()
      require('log-highlight').setup {}
    end,
  },
  {
    'nvchad/minty',
    dependencies = { 'nvchad/volt' },
    config = function()
      vim.api.nvim_create_user_command(
        "MintyHue", -- コマンド名
        function()  -- 実行する関数
          require('minty.huefy').open({ border = true })
        end,
        { nargs = 0 } -- コマンドに引数がない場合は`nargs = 0`
      )

      vim.api.nvim_create_user_command(
        "MintyShade", -- もう1つのコマンド名
        function()
          print("MintyShade command executed!")
        end,
        { nargs = 0 } -- 引数なしの設定
      )
    end,
    cmd = { 'MintyHue', 'MintyShade' }
  },

}

return spec
