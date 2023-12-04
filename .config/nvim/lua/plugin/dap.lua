local spec = {

  {
    'mfussenegger/nvim-dap',
    config = function()
      dap_setup()
    end,
    keys = {
      { "<leader>6",         ":lua require'dap'.continue()<CR>" },
      { "<leader>7",         ":lua require'dap'.step_over()<CR>" },
      { "<leader>8",         ":lua require'dap'.step_into()<CR>" },
      { "<leader>9",         ":lua require'dap'.step_out()<CR>" },
      { "<leader>;",         ":lua require'dap'.toggle_breakpoint()<CR>" },
      { "<leader>'",         ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>" },
      { "<leader>i",         ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", },
      { "<leader>d",         ":lua require'dapui'.toggle()<CR>", },
      { "<leader><leader>d", ":lua require'dapui'.eval()<CR>" },
    },
    dependencies = { "rcarriga/nvim-dap-ui", 'nvim-telescope/telescope.nvim' },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-treesitter' },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  },
  {
    'simrat39/rust-tools.nvim',
    ft = { 'rust' },
  }

}


function dap_setup()
  local status, telescope = pcall(require, "telescope")
  if not status then return end
  telescope.load_extension("dap")


  local status, dap = pcall(require, 'dap')
  if not status then return end

  local status, dapui = pcall(require, 'dapui')
  if not status then return end

  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
    mappings = {
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40,
        position = "left",
      },
      {
        elements = {
          "repl",
        },
        size = 0.25,
        position = "bottom",
      },
    },
    controls = {
      enabled = true,
      element = "repl",
      icons = {
        pause = "",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "↻",
        terminate = "□",
      },
    },
    floating = {
      max_height = nil,
      max_width = nil,
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil,
      max_value_lines = 100,
    },
  })

  dap.adapters = {
    codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        -- Masonはここにデバッガを入れてくれる
        command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb',
        -- ポートを自動的に割り振ってくれる
        args = { '--port', '${port}' }
      }
    }
  }
  dap.configurations.rust = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }
end

return spec
