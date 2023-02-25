local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then return end

ts.setup {
  highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" },
  },
  indent = { enable = false, disable = { 'python' } },
  ensure_installed = {
    "tsx", "toml", "php", "json", "yaml", "css", "html", "lua", "python",
    "cpp", "markdown", "markdown_inline",
  },
  autotag = { enable = true },
  yati = { enable = true,
    indent = { enable = false } }
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
