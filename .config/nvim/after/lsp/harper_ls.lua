local filetypes = vim.tbl_keys(vim.filetype._get_known_filetypes())
table.sort(filetypes)

return {
  filetypes = filetypes,
  settings = {
    ["harper-ls"] = {
      linters = {
        SentenceCapitalization = false,
      },
    },
  },
}
