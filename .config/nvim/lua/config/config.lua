vim.g.python3_host_prog = "$HOME/neovim_venv/neovim/bin/python"
-- リーダーキーの設定
vim.g.mapleader = " "
vim.cmd([[lang en_US.UTF-8]])
-- 文字コード
vim.scriptencoding = "UTF-8"
vim.opt.encoding = "UTF-8"
vim.opt.fileencodings = { "utf-8", "shift-jis", "default", "latin1" }
-- 文字幅
vim.opt.ambiwidth = "single"
-- ベルの音をミュート
vim.opt.belloff = "all"
-- 相対行番号の表示
vim.opt.relativenumber = true
-- 行番号の表示
vim.opt.number = true
-- statuscolの固定長
vim.opt.signcolumn = "yes:1"
-- 背景色
vim.opt.background = "dark"
-- tabをスペース
vim.opt.expandtab = true
-- tabを半角スペース2コ
vim.opt.tabstop = 2
-- tabの幅
vim.opt.shiftwidth = 2
-- マウスの有効化
vim.opt.mouse = "a"
-- 大小文字を区別しない
vim.opt.ignorecase = true
-- 大文字がある時はignorecaseを無視
vim.opt.smartcase = true
-- カーソル行をハイライト
vim.opt.cursorline = true
-- 行番号のみハイライト
vim.opt.cursorlineopt = "number"
-- 検索移動
vim.opt.incsearch = true
-- 検索ループ
vim.opt.wrapscan = true
-- 置換を可視化
vim.opt.inccommand = "split"
-- 改行，タブの可視化
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "⋅", nbsp = "␣", extends = "❯", precedes = "❮" }
-- オートインデント
vim.opt.autoindent = true
-- スマートインデント
vim.opt.smartindent = true
-- かっこの対応
vim.opt.showmatch = true
-- 検索のハイライト
vim.opt.hls = true
-- バックアップファイルの削除
vim.opt.swapfile = false
vim.opt.backup = false
-- undoの永続化
vim.opt.undofile = true
-- 下，右に分割
vim.opt.splitbelow = true
vim.opt.splitright = true
-- カーソルを真ん中に
vim.opt.scrolloff = 5
-- 自動外部読み込み https://vim-jp.org/vim-users-jp/2011/03/12/Hack-206.html
vim.opt.autoread = true
vim.api.nvim_exec(
	[[
  augroup autoread
    autocmd!
    autocmd WinEnter,BufEnter * checktime
  augroup END
]],
	false
)
-- popupオプション
vim.opt.wildoptions = "pum"
-- フォーマットオプション 改行の時コメントアウトさせない ftpluginで上書き
vim.api.nvim_exec(
	[[
  au FileType * if match(&ft, 'markdown\|markdown') == -1 | set fo-=c fo-=r fo-=o | endif
]],
	false
)
-- ターミナルの分割を行う
if vim.fn.has("nvim") == 1 then
	vim.cmd([[command! -nargs=* Term split | terminal <args>]])
	vim.cmd([[command! -nargs=* Termv vsplit | terminal <args>]])
end
-- 一番上を選択
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.path:append({ "**" })
-- remove cmd height
vim.opt.cmdheight = 0
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.matchpairs:append({
	"<:>",
	"「:」",
	"（:）",
	"『:』",
	"【:】",
	"《:》",
	"〈:〉",
	"｛:｝",
	"［:］",
	"‘:’",
	"“:”",
})

-- remember folds
vim.api.nvim_exec(
	[[
  augroup remember_folds
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview
  augroup END
]],
	false
)

-- v0.12 extui http://zenn.dev/kawarimidoll/articles/4da7458c102c1f
-- local ok, extui = pcall(require, "vim._extui")
-- if ok then
-- 	print("Now, the version of vim is 0.12. If you check this message, you can delete it.")
-- 	extui.enable({
-- 		enable = true, -- extuiを有効化
-- 		msg = {
-- 			pos = "cmd", -- 'box'か'cmd'だがcmdheight=0だとどっちでも良い？（記事後述）
-- 			box = {
-- 				timeout = 5000, -- boxメッセージの表示時間 ミリ秒
-- 			},
-- 		},
-- 	})
-- end

-- すべてのバッファのフルパスをクリップボードにコピーするコマンド
vim.api.nvim_create_user_command("CopyAllBufferPaths", function()
	-- buflistedで、かつファイル名が空でないバッファのみを対象
	local bufs = vim.tbl_filter(function(bufnr)
		return vim.bo[bufnr].buflisted and vim.api.nvim_buf_get_name(bufnr) ~= ""
	end, vim.api.nvim_list_bufs())

	local paths = vim.tbl_map(vim.api.nvim_buf_get_name, bufs)
	local result = table.concat(paths, "\n")

	if result ~= "" then
		vim.fn.setreg("+", result)
		-- 表示するメッセージを短縮
		local count = #paths
		print("Copied " .. count .. " buffer paths.")
	else
		print("No buffer paths to copy.")
	end
end, { desc = "Copy all listed buffer full paths to clipboard" })

-- ccb の定義 (CopyCurrentBufferPathの省略形)
vim.api.nvim_create_user_command(
	"CCB",
	"CopyCurrentBufferPath", -- 既存のコマンドを呼び出す
	{ desc = "Alias for CopyCurrentBufferPath" }
)

-- cab の定義 (CopyAllBufferPathsの省略形)
vim.api.nvim_create_user_command(
	"CAB",
	"CopyAllBufferPaths", -- 既存のコマンドを呼び出す
	{ desc = "Alias for CopyAllBufferPaths" }
)

-- 現在のバッファのフルパスをクリップボードにコピーするコマンド
vim.api.nvim_create_user_command("CopyCurrentBufferPath", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("Copied: " .. path)
end, { desc = "Copy current buffer full path to clipboard" })
-- 外部からファイルを変更されたら反映する
-- https://minerva.mamansoft.net/Notes/%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%8C%E5%A4%89%E6%9B%B4%E3%81%95%E3%82%8C%E3%81%9F%E3%82%89%E8%87%AA%E5%8B%95%E3%81%A7%E5%86%8D%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%81%BF+(Neovim)
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})
