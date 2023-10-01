-- Normal setup
local status, rt = pcall(require, "rust-tools")
if not status then return end

local extension_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/'
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

-- local this_os = vim.loop.os_uname().sysname;
--
-- -- The path in windows is different
-- if this_os:find "Windows" then
--   codelldb_path = extension_path .. "adapter\\codelldb.exe"
--   liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
-- else
--   -- The liblldb extension is .so for linux and .dylib for macOS
--   liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
-- end
--
rt.setup({
  dap = {
    adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
  },
  server = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<Leader>da", rt.hover_actions.hover_actions, { buffer = bufnr })
    end,
  },
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
})
