local status, dap = pcall(require, 'dap')
if not status then return end

local status, dapui = pcall(require, 'dapui')
if not status then return end
dapui.setup()


dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

local set = vim.keymap.set
set("n", "<Leader>dt", ':DapToggleBreakpoint<CR>')
set("n", "<Leader>dx", ':DapTerminate<CR>')
set("n", "<Leader>do", ':DapStepOver<CR>')

set('n', '<Leader>dc', function() dap.continue() end)
set('n', '<Leader>do', function() dap.step_over() end)
set('n', '<Leader>di', function() dap.step_into() end)
set('n', '<Leader>dp', function() dap.step_out() end)
set('n', '<Leader>db', function() dap.toggle_breakpoint() end)
set('n', '<Leader>dl', function() dap.run_last() end)
set('n', '<Leader>df', function() require("dapui").float_element('scopes', { enter = true }) end)
set('n', '<Leader>dr', function() dap.repl.toggle() end)


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
