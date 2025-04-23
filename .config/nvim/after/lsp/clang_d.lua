local status, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status then
  print('cmp_nvim_lsp not found')
  return
end
local capabilities = cmp_nvim_lsp.default_capabilities()
capabilities.offsetEncoding = { "utf-16" }

return {
  capabilities = capabilities,
}
