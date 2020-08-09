# CheatSheet

## normal mode

- gu 小文字に
- gU 大文字に
- <Leader>h,j,k,l ウィンドウの移動

- <S-h> 定義をホバーして表示
- <leader> f フォーマットする
- <leader> n 次のエラーに移動
- <leader> p 前のエラーに移動
- <leader> b ファイルツリーを表示
- <ESC><ESC> :nohとおなじ
- <leader> gd 定義に移動
- <leader> gy 型を確認
- <leader> gi 実装に移動
- <leader> gr 参照に移動
- <leader><TAB> 表示するバッファを切り替える
- <leader>om マークダウンを開く
- <C-w><C-w> ウィンドウの移動
- <C-T> ウィンドウのリサイズ
## command line mode

- :new {file} 上下に分割
- :vnew {file} 左右に分割
- :sp {file} 上下に分割
- :vs {file} 左右に分割
- :tabnew {file} タブを開く
- [N]gt タブを移動する
- :tabo 現在以外のタブを消す
- edit <buffer> バッファを変える
- :PrevimOpen マークダウンのプレビューを開く
- :e 今のバッファの再読み込み
- :bufdo e 全バッファの再読み込み
- :tabdo e 全タブの再読み込み
- :b [数字] バッファの移動
- :bd [数字] バッファの削除

## NERDTree

- o <CR> ファイルを開く
- t 新しいタブで開く
- i 上下分割で開く
- s 左右分割で開く
- go,t,i,s フォーカスそのまま 

- o ディレクトリを開く
- O 全展開
- x 閉じる 
- X 全閉じる

## commentout

ビジュアルモードで
- gc コメントアウト
- gcc コメントアウト解除

## IPython

- ヴィジュアルモード で<leader>ip  IPythonを起動する
