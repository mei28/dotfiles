return {
  filetypes = { "nix" },
  settings = {
    ['nil'] = {
      testSetting = 42,
      formatting = {
        command = { "nixfmt" },
      },
    },
  }
}
