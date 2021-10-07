" activateしている仮想環境があればそっちにはいる
" if exists("$VIRTUAL_ENV")
"   let g:python3_host_prog = $VIRTUAL_ENV . '/bin/python'
" else
"   let g:python3_host_prog = '/Users/mei/.venv/neovim/bin/python'
" endif
let g:python3_host_prog = '/Users/mei/.venv/neovim/bin/python'

" リーダキーの設定
let mapleader = "\<Space>"
set encoding=UTF-8 "文字コード
set fileencoding=utf-8
lang en_US.UTF-8

" dein plugin manager
if &compatible
 set nocompatible
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein')
 call dein#begin('~/.cache/dein')
 call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
 call dein#load_toml('~/.config/nvim/dein_ddc.toml', {'lazy': 1})
 call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})
 call dein#end()
 call dein#save_state()
endif
if dein#check_install()
  call dein#install()
endif
filetype plugin indent on
syntax enable

" ターミナルの分割を行う
if has('nvim')
  command! -nargs=* Term split | terminal <args>
  command! -nargs=* Termv vsplit | terminal <args>
endif


" カラースキーム {{{
set termguicolors
colorscheme iceberg
" colorscheme nord
" colorscheme tokyonight
set bg=dark
set pumblend=10
set winblend=10

set ambiwidth=single
set belloff=all "ベルの音をミュート
set relativenumber "行の相対番号を表示
set number "行番号表示
set expandtab "tabをスペースで
set tabstop=2 "tabで半角2文字
set shiftwidth=2 "tabの幅
set mouse=a "マウスの有効化
set ignorecase "大文字小文字を区別しない
set smartcase "大文字があるときはignorecaseを無視
set cursorline "カーソル行をハイライト
" 行番号のみハイライト
if !has('nvim')
  set cursorlineopt=number
endif
set incsearch "検索を移動
set wrapscan "検索をループ
set inccommand=split "置換のとき可視化
if has("mac") | set clipboard+=unnamed | else | set clipboard^=unnamedplus | endif " clipboardをOSのものと同じに
set list "改行，タブとかを可視化 
set smartindent "スマートインデント
set autoindent "オートインデント
set showmatch "対応するかっこ
set hls "検索のハイライト
"自動的に作られるうざいバックアップを消す
set noswapfile
set nobackup
set nowritebackup
set undofile "undoの永続化
"下に分割 右に分割
set splitbelow
set splitright
set scrolloff=42 "カーソルが常に真ん中に
set autoread "外部に変更があった時に読み込む
let g:go_def_reuse_buffer = 1 " 開いているバッファに定義ジャンプをする
filetype plugin indent on " filetypeによって設定を変える
au FileType * set fo-=c fo-=r fo-=o " 改行時にコメントアウトさせない
set wildoptions=pum " コマンドラインの補完をpopupにする


" *でカーソル移動させない
noremap * *N
" #でカーソル移動させない
noremap # #N
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

nnoremap <silent> <C-a> <Home>
nnoremap <silent> <C-e> <End>
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

" inoremap <silent> <Esc> <Esc><C-l> "画面をクリアした後にノーマルモードに戻る

nnoremap <silent> <C-o> <C-i> "以前いた場所に戻る
nnoremap <silent> <C-i> <C-o> "元いた場所に進む

" xで削除してもコピーさせない
nnoremap x "_x

" ESC連打で:nohを行う
nnoremap <silent> <Esc><Esc> :noh<CR><C-l>
" 表示行単位で上下移動を行う
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> gj j
nnoremap <silent> gk k
" 分割ウィンドウの移動
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>hh <C-w>h
nnoremap <Leader>l <C-w>l

" 補完表示時のEnterで改行をしない
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
" 一番上を選択　
set completeopt=menuone,noinsert

" 上下を決める
inoremap <expr><TAB> pumvisible() ? "<Down>" : "<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "<Up>" : "<S-TAB>"

" ターミナルモードでコマンドに戻るようにする
tnoremap <Esc> <C-\><C-n>

" pysen用の設定
set makeprg=pysen\ run_files\ --error-format\ gnu\ lint\ %
