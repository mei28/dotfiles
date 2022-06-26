  -- Use around source.
  vim.call[[ddc#custom#patch_global('sources', ['around','nvim-lsp','file','buffer'])]]

  -- Use ddc.
  vim.call[[ddc#enable()]] 
