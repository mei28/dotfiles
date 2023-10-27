vim.g.python3_host_prog = '$HOME/.venv/neovim/bin/python'
-- リーダーキーの設定
vim.g.mapleader = ' '
vim.cmd [[lang en_US.UTF-8]]
-- 文字コード
vim.scriptencoding = 'UTF-8'
vim.opt.encoding = 'UTF-8'
vim.opt.fileencoding = 'UTF-8'
-- 文字幅
vim.opt.ambiwidth = 'single'
-- ベルの音をミュート
vim.opt.belloff = 'all'
-- 相対行番号の表示
vim.opt.relativenumber = true
-- 行番号の表示
vim.opt.number = true
-- 背景色
vim.opt.background = 'dark'
-- tabをスペース
vim.opt.expandtab = true
-- tabを半角スペース2コ
vim.opt.tabstop = 2
-- tabの幅
vim.opt.shiftwidth = 2
-- マウスの有効化
vim.opt.mouse = 'a'
-- 大小文字を区別しない
vim.opt.ignorecase = true
-- 大文字がある時はignorecaseを無視
vim.opt.smartcase = true
-- カーソル行をハイライト
vim.opt.cursorline = true
-- 行番号のみハイライト
vim.opt.cursorlineopt = 'number'
-- 検索移動
vim.opt.incsearch = true
-- 検索ループ
vim.opt.wrapscan = true
-- 置換を可視化
vim.opt.inccommand = 'split'
-- 改行，タブの可視化
vim.opt.list = true
vim.opt.listchars = { tab = '>>', trail = '·', nbsp = '+' }
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
vim.opt.scrolloff = 999
-- 自動外部読み込み
vim.opt.autoread = true
-- popupオプション
vim.opt.wildoptions = 'pum'
-- フォーマットオプション 改行の時コメントアウトさせない
vim.api.nvim_exec([[
  au FileType * if match(&ft, 'markdown\|markdown') == -1 | set fo-=c fo-=r fo-=o | endif
]], false)
-- ターミナルの分割を行う
if vim.fn.has('nvim') == 1 then
  vim.cmd [[command! -nargs=* Term split | terminal <args>]]
  vim.cmd [[command! -nargs=* Termv vsplit | terminal <args>]]
end
-- 一番上を選択
vim.opt.completeopt = 'menuone,noinsert,noselect'
vim.opt.path:append { '**' }
-- remove cmd height
vim.opt.cmdheight = 0
vim.opt.laststatus = 2
vim.opt.showmode = false

-- remember folds
vim.api.nvim_exec([[
  augroup remember_folds
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview
  augroup END
]], false)

