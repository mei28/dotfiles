-- copilot-language-server は workspace folder があるほど提案の質が上がる。
-- lspconfig の既定は root_markers = { '.git' } のみで、リポジトリ外のファイル
-- (claude / codex の editor mode が開く /tmp 配下の一時ファイルなど) では
-- root_dir が nil になり workspace 無しで動いてしまう。
-- マーカーが見つからない場合は nvim の cwd を workspace として渡す。
--- @type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { '.git', '.jj' }) or vim.fn.getcwd())
  end,
}
