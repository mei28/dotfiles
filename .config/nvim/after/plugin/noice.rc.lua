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
    },
    views = {
      cmdline_popup = {
        position = {
          row = 5,
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
          row = 8,
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
    },
  }
)
