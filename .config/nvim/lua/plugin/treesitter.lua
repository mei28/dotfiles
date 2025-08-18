local spec = {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufNewFile', 'BufRead' },
    branch = 'main',
    build = { ':TSInstall! vim', ':TSUpdate' },
    config = function() treesitter_setup() end
  },
  -- {
  --   'yioneko/nvim-yati',
  --   event = { 'BufNewFile', 'BufRead' },
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  --   config = function()
  --   end
  -- },
}

function treesitter_setup()
  local status, ts = pcall(require, 'nvim-treesitter')
  if not status then return end

  ts.setup {
    -- Directory to install parsers and queries to
    install_dir = vim.fn.stdpath('data') .. '/site'
  }
  local installed_parser = {
    "tsx",
    "toml",
    "php",
    "json",
    "yaml",
    "css",
    "html",
    "lua",
    "python",
    "cpp",
    "markdown",
    "markdown_inline",
    'vim',
    'rust',
    'dockerfile',
    'make',
    'go',
  }
  ts.install { installed_parser }


  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = installed_parser,
    callback = function()
      -- syntax highlighting, provided by Neovim
      vim.treesitter.start()
      -- folds, provided by Neovim
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      -- indentation, provided by nvim-treesitter
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  -- ts.setup {
  --   highlight = {
  --     enable = true,
  --     additional_vim_regex_highlighting = { "markdown" },
  --     disable = function(lang, buf)
  --       local max_filesize = 100 * 1024 -- 100 KB
  --       local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
  --       if ok and stats and stats.size > max_filesize then
  --         vim.api.nvim_out_write("Warning: File size exceeds 100KB. Disabling Treesitter highlighting.\n")
  --         return true
  --       end
  --     end,
  --   },
  --   indent = { enable = false, disable = { 'python' } },
  --   ensure_installed = {
  --   },
  --   yati = {
  --     enable = true,
  --     indent = { enable = false }
  --   }
  -- }
  --
  -- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  -- parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
end

return spec
