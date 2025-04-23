local status, lspconfig = pcall(require, 'lspconfig')
if not status then return end

return {
  filetypes = { "rust" },
  -- root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
  settings = {
    ['rust_analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      -- enable clippy on save
      check = {
        command = "clippy",
      },
    }
  }
}
