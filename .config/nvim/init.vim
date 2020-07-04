syntax on
set t_Co=256 "色
set background=dark

colorscheme iceberg "カラースキームをiceberg

set encoding=utf-8 "文字コード
set number "行番号表示
set expandtab "tabをスペースで
set tabstop=2 "tabで半角2文字
set shiftwidth=2 "tabの幅
set mouse=a "マウスの有効化
set ignorecase "大文字小文字を区別しない
set smartcase "大文字があるときはignorecaseを無視
set cursorline "カーソル行をハイライト
set incsearch "検索を移動
set wrapscan "検索をループ
set inccommand=split "置換のとき可視化
set clipboard+=unnamed "clipboardをOSのものと同じに
set list "改行，タブとかを可視化
set smartindent "スマートインデント
set autoindent "オートインデント
set showmatch "対応するかっこ
set hls "検索のハイライト
"自動的に作られるうざいバックアップを消す
set noswapfile
set nobackup
set nowritebackup

" jjでnormal modeに，そして保存
inoremap <silent> jj <ESC>:<C-u>w<CR> 
" キーマップを設定
inoremap <silent> <C-f> <Right>
inoremap <silent> <C-b> <Left>
inoremap <silent> <C-p> <Up>
inoremap <silent> <C-n> <Down>
inoremap <silent> <C-a> <Home>
inoremap <silent> <C-e> <End>
inoremap <silent> <C-d> <Del>
inoremap <silent> <C-h> <BS>
inoremap <silent> <C-j> <F6>
inoremap <silent> <C-k> <F7>
inoremap <silent> <C-l> <F9>
inoremap <silent> <C-;> <F10>

cnoremap <silent> <C-f> <Right>
cnoremap <silent> <C-b> <Left>
cnoremap <silent> <C-p> <Up>
cnoremap <silent> <C-n> <Down>
cnoremap <silent> <C-a> <Home>
cnoremap <silent> <C-e> <End>
cnoremap <silent> <C-d> <Del>
cnoremap <silent> <C-h> <BS>
cnoremap <silent> <C-j> <F6>
cnoremap <silent> <C-k> <F7>
cnoremap <silent> <C-l> <F9>
cnoremap <silent> <C-;> <F10>

nnoremap <silent> <Esc><Esc> :noh<CR>


" dein plugin manager
if &compatible
 set nocompatible
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein')
 call dein#begin('~/.cache/dein')
 call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
 call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})
 call dein#end()
 call dein#save_state()
endif
if dein#check_install()
  call dein#install()
endif
filetype plugin indent on
syntax enable
