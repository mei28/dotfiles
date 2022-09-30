vim.g.python3_host_prog='$HOME/.venv/neovim/bin/python'
-- リーダーキーの設定
vim.g.mapleader=' '
vim.cmd[[lang en_US.UTF-8]]

-- 文字コード
vim.scriptencoding='UTF-8'
vim.o.encoding='UTF-8'
vim.o.fileencoding='UTF-8'
-- 文字幅
vim.o.ambiwidth=single
-- ベルの音をミュート
vim.o.belloff=all
-- 相対行番号の表示
vim.o.relativenumber=true
-- 行番号の表示
vim.o.number=true
-- 背景色
vim.o.background='dark'
-- tabをスペース
vim.o.expandtab=true
-- tabを半角スペース2コ
vim.o.tabstop=2
-- tabの幅
vim.o.shiftwidth=2
-- マウスの有効化
vim.o.mouse=true
-- 大小文字を区別しない
vim.o.ignorecase=true
-- 大文字がある時はignorecaseを無視
vim.o.smartcase=true
-- カーソル行をハイライト
vim.o.cursorline=true
-- 行番号のみハイライト
vim.o.cursorlineopt='number'
-- 検索移動
vim.o.incsearch=true
-- 検索ループ
vim.o.wrapscan=true
-- 置換を可視化
vim.o.inccommand='split'
-- 改行，タブの可視化
vim.o.list=true
-- オートインデント
vim.o.autoindent=true
-- スマートインデント
vim.o.smartindent=true
-- かっこの対応
vim.o.showmatch=true
-- 検索のハイライト
vim.o.hls=true
-- バックアップファイルの削除
vim.b.noswapfile=true
vim.b.nobackup=true
vim.b.nowritebackup=true

-- undoの永続化
vim.bo.undofile=true
-- 下，右に分割
vim.o.splitbelow=true
vim.o.splitright=true
-- カーソルを真ん中に
vim.o.scrolloff=42
-- 自動外部読み込み
vim.o.autoread=true
-- popupオプション
vim.o.wildoptions='pum'
-- フォーマットオプション 改行の時コメントアウトさせない
vim.cmd[[au FileType * set fo-=c fo-=r fo-=o]]

-- ターミナルの分割を行う
if vim.fn.has('nvim')==1 then
  vim.cmd[[command! -nargs=* Term split | terminal <args>]]
  vim.cmd[[command! -nargs=* Termv vsplit | terminal <args>]]
end

-- 一番上を選択
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.opt.path:append { '**' }

-- remove cmd height
vim.o.cmdheight=0
vim.o.laststatus=2
vim.o.showmode=false
