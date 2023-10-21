local spec = {

  --- noice
  {
    "folke/noice.nvim",
    event = "ModeChanged",
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- "rcarriga/nvim-notify",
    },
    config = function() noice_setup() end,
  },
  -- {
  --   "rcarriga/nvim-notify",
  --   event = "ModeChanged",
  --   config = function() notify_setup() end,
  --
  -- }
}

function noice_setup()
  local status, noice = pcall(require, 'noice')

  if not status then return end

  noice.setup(
    {
      lsp = {
        signature = {
          auto_open = {
            enabled = false,
            -- throttle = 0, -- Debounce lsp signature help request by 50ms
          },
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = "10%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = "10%",
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
        confirm = {
          position = {
            row = "10%",
            col = "50%",
          },
        },
      },
    }
  )
end

function notify_setup()
  local status, notify = pcall(require, 'notify')
  if not status then return end

  notify.setup({
    render = "minimal",
    stages = "fade",
    timeout = 1,
  })
end

return spec
