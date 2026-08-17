# herdr × bonsai 運用ガイド

作業を並行させるための下地を、bonsai と herdr で二層に分けて用意する。
bonsai が git worktree を作り、herdr がその worktree を workspace として開いてエージェントを住まわせる。
両者をつなぐ手順は `bonsai-herdr` skill に畳み込んであり、Claude Code のセッションから呼び出せる。

本ガイドは herdr 0.7.4 と bonsai 0.1.5 で実機確認した内容に基づく。
掲載したコマンドはすべて `--help` で存在を確認している。

## 役割分担

| 層 | 担当 | 具体物 |
|---|---|---|
| worktree の作成 / 命名 / 削除 | bonsai | `.bonsai/<branch>` 配下のチェックアウト |
| workspace / tab / pane / agent のライフサイクル | herdr | 端末の分割とエージェントの起動 |
| 分解 / 指示 / 監視 / 収穫 / マージ | Claude Code のセッション | `bonsai-herdr` skill |

```
  bonsai                                   herdr
  ┌────────────────────────┐              ┌──────────────────────────┐
  │ main worktree           │              │ workspace  (repo 1 checkout)│
  │ /Users/mei/dotfiles     │              │   └ tab                    │
  └───────────┬────────────┘              │       └ pane (agent 1つ)   │
              │ bonsai add -c <branch>     └──────────────────────────┘
              ▼                                        ▲
  .bonsai/<branch>  ──── herdr worktree open ──────────┘
                    ──── herdr agent rename ────▶ root pane に名前を付ける
                    ──── herdr pane run     ────▶ その pane の shell で claude を起動
```

worktree と workspace は一対一で対応させる。
この対応が崩れると、どのエージェントがどのブランチを触っているのか追えなくなる。

## 構成の考え方

- 両ツールとも nix の flake input で管理する。
  `flake.nix` の `bonsai`（`github:mei28/bonsai`）と `herdr`（`github:ogulcancelik/herdr/v0.7.4`）が実体。
  herdr は各ホスト（`hosts/babalab-mac.nix` など）、bonsai は `profiles/development.nix` で入れている。
- herdr の設定は `config.toml` と `bin/` だけを symlink する。
  `~/.config/herdr/sessions/` は実行時状態なので symlink の対象から外してある（`profiles/base.nix`）。
  セッションのログとソケットがそこに置かれるためだ。
- bonsai の設定はリポジトリごとの `.bonsai.toml`。
  `worktree_dir = ".bonsai"` で worktree の置き場を決める。
- `.bonsai` と `.tmp` は `modules/git.nix` の `ignores` に入っている。
  worktree をリポジトリ内に置いても git の追跡対象にはならない。

## 初回セットアップ

| 手順 | コマンド | 備考 |
|---|---|---|
| 1. nix 適用 | `just build <host>` → `just update <host>` | herdr と bonsai の両バイナリ、herdr の config symlink を入れる |
| 2. shell 統合 | `.bashrc` の `eval "$(bonsai shell-init bash)"` | bonsai を関数として定義する。後述の挙動に注意 |
| 3. リポジトリ初期化 | `bonsai init` | `.bonsai.toml` を書き、`.gitignore` に `.bonsai/` を足す。リポジトリを変更するので確認してから実行する |
| 4. agent 検出フック | `herdr integration install claude` | 状態を herdr に報告するフックを入れる |
| 5. 確認 | `herdr status` / `herdr integration status` | server が running、claude が current であること |

初期化済みかどうかは `.bonsai.toml` の有無で判断する。
未初期化でも `bonsai list` は通常どおり一覧を表示し、`bonsai add` になって初めて落ちるためだ。
`bonsai init --dry-run` で下見はできない。0.1.5 では dry-run と称して実際に書き込む。

`herdr integration status` は導入済みのフックを一覧する。
確認時点では claude、codex、copilot が入っている。
`agy`（Antigravity CLI）は herdr の対応エージェント一覧に含まれない。
そのため Antigravity は本ガイドの並列運用の対象外とする（`docs/antigravity.md` と同じ判断）。

## bonsai による worktree 管理

### コマンド

| コマンド | 役割 |
|---|---|
| `bonsai init` | リポジトリに `.bonsai.toml` を作る |
| `bonsai add -c <branch> --base <base>` | ブランチを新規作成して worktree を追加する |
| `bonsai list` | worktree の一覧。`--porcelain` `--status` `--names-only` あり |
| `bonsai cd <worktree>` | worktree のパスを出力する。`@` で main、`-` で直前 |
| `bonsai status [worktree]` | worktree ごとの git status |
| `bonsai remove <worktree>` | worktree を削除する。`--with-branch` でブランチも消す |
| `bonsai prune` | マージ済み（`--merged`）や放置（`--stale N`）の worktree をまとめて削除する |
| `bonsai rename <old> <new>` | ブランチ名の変更とディレクトリの移動を同時に行う |
| `bonsai shell-init <shell>` | shell 統合スクリプトを出力する |

### 典型的な流れ

```bash
bonsai add -c feat-x --base main   # .bonsai/feat-x に worktree ができる
bonsai cd feat-x                   # 対話 shell ではそこへ移動する
# 作業してコミット
bonsai cd @                        # main worktree へ戻る
bonsai remove feat-x               # 片付ける
```

`bonsai add` は `.bonsai.toml` の `worktree_dir` に従って配置先を決める。
このリポジトリでは `.bonsai/<branch>` になる。

### `bonsai cd` はディレクトリを移動する

shell 統合を入れると、`bonsai` はバイナリではなく関数になる。
この関数は第一引数が `cd` のときだけ挙動を変え、バイナリの出力したパスを `builtin cd` に渡す。
シェルの子プロセスは親のカレントディレクトリを変えられないので、この迂回が必要になる。

```bash
$ type bonsai
bonsai is a function
```

そのため、スクリプトの中で `bonsai cd` の出力を受け取ろうとすると空になる。
関数はパスを出力せず、移動してしまうためだ。

```bash
$ WT=$(bonsai cd docs-herdr);         echo "[$WT]"
[]
$ WT=$(command bonsai cd docs-herdr); echo "[$WT]"
[/Users/mei/dotfiles/.bonsai/docs-herdr]
```

パスを値として使うときは `command bonsai cd` と書く。
`--help` も同じ理由で関数を通せない。
`bonsai cd --help` はヘルプ文字列そのものへ `cd` を試みて `File name too long` で失敗する。

```bash
command bonsai cd --help      # ヘルプを読むときもこちら
```

この落とし穴は `cd` サブコマンドに限られる。
それ以外のサブコマンドは関数が `command bonsai "$@"` にそのまま渡すため、通常どおり動く。

なお `shell-init` は bash、zsh、fish、elvish、powershell を出力できるが、このリポジトリが読み込んでいるのは bash 版だけである（`.bashrc`）。
zsh を使う場合は同じ要領で `bonsai shell-init zsh` を読み込む必要がある。

## herdr による端末の管理

### 概念

- **workspace**：プロジェクトの単位。ここでは worktree ひとつに対応させる。
- **tab**：workspace の中の下位文脈。
- **pane**：tab の中の端末分割。ひとつのプロセス（shell、エージェント、サーバ、ログ）が動く。
- **agent status**：herdr が自動検出する状態。`idle` `working` `blocked` `done` `unknown` の五つ。
  `done` は「終わったがまだ人間が見ていない」を意味する。

### ID と環境変数

ID は稼働中のセッションに閉じた短い識別子で、実行中の herdr から読み直して使う。
0.7.4 では workspace が `wF`、tab が `wF:t1`、pane が `wF:p2` の形になる。
pane や tab を閉じると詰め直されるため、以前に見た ID が同じ対象を指す保証はない。
必要になった時点で `herdr workspace list` や `herdr pane list`、`herdr agent list` から読み直す。

自分自身の位置は環境変数から取る。
`herdr pane list` から探し当てるより確実で、他のペインと取り違えない。

| 変数 | 内容 |
|---|---|
| `HERDR_ENV` | herdr 配下なら `1` |
| `HERDR_WORKSPACE_ID` | 自分の workspace ID |
| `HERDR_TAB_ID` | 自分の tab ID |
| `HERDR_PANE_ID` | 自分の pane ID |
| `HERDR_SESSION` | セッション名（既定は `main`） |
| `HERDR_SOCKET_PATH` | CLI が話す unix socket |

### 主なコマンド

```bash
herdr workspace list                       # workspace 一覧（json）
herdr workspace close <workspace_id>

herdr worktree list [--json]               # repo の worktree と開いている workspace の対応
herdr worktree open --path <path> --label <text> --no-focus --json
herdr worktree create --branch <name> --base <ref> --json

herdr tab create --workspace <id> --label <text>
herdr pane split <pane_id> --direction right|down --no-focus
herdr pane run <pane_id> "<command>"       # テキスト送信 + Enter
herdr pane send-text <pane_id> "<text>"    # Enter を送らない
herdr pane send-keys <pane_id> Enter
herdr pane read <pane_id> --source recent --lines 80
herdr pane close <pane_id>

herdr agent list                           # 検出済みエージェントと状態
herdr agent rename <pane_id> <name>        # pane に名前を付ける。エージェント未検出でもよい
herdr agent start <name> --cwd <path> --workspace <id> --no-focus -- claude
herdr agent read <name> --source recent --lines 80
herdr agent send <name> "<text>"           # 文字だけ。Enter は送らない
```

`herdr worktree open` は既にその path に workspace があると `already_open: true` を返す。
その場合は既存の workspace を再利用し、新しく開き直さない。

`herdr agent start` はエージェントを pane 自身のプロセスとして起動する。
そのため中断や終了が pane ごと落とすことになり、長時間動かすエージェントには向かない（後述）。

`herdr agent rename` で付けた `<name>` は、ID と違って安定した取っ手になる。
以後の `agent read` や `agent send` はこの名前で対象を指定できる。
`rename` はエージェントがまだ検出されていない pane も受け付けるため、起動前に名前を確定できる。
名前は herdr インスタンス全体で解決されるため、別リポジトリの実行が同じ名前を使っていると誤送信になる。
`herdr agent list` で衝突を確認し、必要ならリポジトリ名を前置する。

### 待ち受けの注意

`herdr wait agent-status` と `herdr agent wait` はエッジトリガである。
状態が変わった瞬間を捉える設計なので、その瞬間を逃すと以後は発火せずタイムアウトする。
タイムアウトは「まだ動いている」証拠にならない。
状態を知りたいときは `herdr agent list` を読み直してポーリングする。

## bonsai-herdr skill

`~/.claude/skills/bonsai-herdr/SKILL.md` が両者をつなぐ手順を持つ。
ファイル範囲が重ならないタスクに分けられる依頼を、タスクごとの worktree と workspace とエージェントに割り当て、ひとつのセッションから監督する。

### 流れ

1. 事前確認。`HERDR_ENV=1`、`herdr` と `bonsai` の両方が PATH にあること、`git status` が空であること、`.bonsai.toml` があること。
   どれも停止条件であり、迂回しない。
   worktree はベースのコミットから枝分かれするため、未コミットの変更は子には渡らない。
2. 分解と承認。ファイル範囲の重ならないタスクに分け、表にして人間の承認を取る。
   同時実行は既定で3つまで。各エージェントが利用者の枠を消費する完全な claude セッションだからだ。
3. タスクごとに `bonsai add -c <branch> --base <base>` で worktree を作る。
4. `herdr worktree open` で workspace を開く。
   できた root pane を `herdr agent rename` で命名し、`herdr pane run` でその pane の shell から claude を起動する。
   `already_open: true` のときは既存の workspace を再利用しつつ、`herdr tab create` でこのタスク専用の tab を足す。
5. `agent-status.sh --registered` で検出を待ってから、`herdr pane run` でタスクを一行で送る。
6. エージェント名でポーリングして監視する。
7. worktree ごとに diff とテストを確認する。
8. 承認を得てからコミットとマージを行い、workspace と worktree を畳む。

### 落とし穴

`herdr worktree open` は必ず root の shell pane を作る。
これを抑制するフラグはない。
そこで pane を増やさず、この root pane の中で claude を起動する。
workspace は最初から pane ひとつで済み、閉じるべき pane も残らない。

`herdr agent start` を使わないのは、pane の寿命が変わるためだ。
`agent start` は claude を pane 自身のプロセスにするので、Ctrl-Z で中断したり claude を終了したりすると pane ごと消え、その中の作業も失われる。
対話 shell から起動しておけば、Ctrl-Z は bash のプロンプトに戻るだけで pane は残る。
実機のペインで確認した挙動である。

命名は claude の起動より先に行う。
`herdr agent rename` はエージェントが検出されていない pane も受け付けるので、起動の競合を待たずに取っ手を確定できる。

その代わり、名前が付いていることは claude が動いていることを意味しない。
`agent-status.sh` は、名前はあるがエージェントが未検出の pane を `starting` として報告する。
`--registered` はこの `starting` が解けるまで、つまり herdr がエージェントを実際に検出するまで待つ。
名前の出現だけを待つのでは、起動途中の pane に指示を送ってしまう。

指示は一行で送る。
テキスト中の改行はエージェントの TUI に送信として届くので、複数行のブリーフは途中で分割されて届き、最初の断片だけで走り出す。

`herdr pane run` はテキストと Enter を送る。
`herdr agent send` は文字を書くだけで Enter を送らないため、プロンプトに置かれたまま送信されない。

worktree は独立したチェックアウトなので、`.tmp/` は子と共有されない。
子に必要な情報はすべて指示文に入れる。

新しい worktree の path は claude にとって初見なので、最初の起動でフォルダの信頼を尋ねることがある。
これは `blocked` として現れ、他の承認と同じく人間に回す。

### 台帳

`.tmp/bonsai-herdr.md` に、タスク、ブランチ、worktree、workspace、エージェント名、コマンド、状態を書く。
herdr の ID は古くなるが、ブランチ名とパスとエージェント名は古くならない。
中断から復帰するときは、この台帳と `herdr agent list` から状態を組み直す。
セッションの途中で覚えた ID からは組み直さない。

### 適用しない場面

- タスクが同じファイルを触る場合。直列に進めると伝える。
- `HERDR_ENV` が `1` でない場合。herdr の外では動かない。
- 自分が既に bonsai-herdr の子として動いている場合。入れ子は許さない。

## ファイル構成

| パス | 役割 |
|---|---|
| `.bonsai.toml` | bonsai のリポジトリ設定。`worktree_dir` で worktree の置き場を決める |
| `.bonsai/<branch>/` | bonsai が作る worktree。git の ignore 対象 |
| `.config/herdr/config.toml` | herdr の設定。テーマ、既定 shell、更新チャンネル、キーバインド |
| `.config/herdr/bin/` | herdr が呼ぶ補助スクリプト |
| `~/.config/herdr/sessions/<name>/` | セッションのソケットとログ。実行時状態なので symlink しない |
| `~/.claude/skills/bonsai-herdr/SKILL.md` | 並列実行の手順 |
| `~/.claude/skills/bonsai-herdr/scripts/agent-status.sh` | エージェント状態のポーリング。終了コードで待ちを制御する |
| `~/.claude/skills/herdr/SKILL.md` | herdr の概念と CLI の一次情報 |
| `~/.claude/hooks/herdr-agent-state.sh` | claude の状態を herdr に報告するフック |
| `.tmp/bonsai-herdr.md` | 並列実行の台帳 |
| `flake.nix` | `bonsai` と `herdr` の flake input |
| `.config/nix/home-manager/profiles/base.nix` | herdr の config.toml と bin/ の symlink |
| `.config/nix/home-manager/profiles/development.nix` | bonsai パッケージ |

## トラブルシュート

- `bonsai cd` の結果が空になる
  → shell 統合の関数が移動してしまっている。`command bonsai cd <name>` を使う。
- `bonsai cd --help` が `File name too long` で落ちる
  → 同じ理由。ヘルプ文字列に `cd` しようとしている。`command bonsai cd --help` を使う。
- `bonsai remove` が未コミットの変更で止まる
  → 内容を確認してから `--force` を付ける。ブランチも消すなら `--with-branch`。
- `herdr` のコマンドが応答しない
  → `herdr status` で server が running か、client と protocol が一致しているかを見る。
  必要なら `herdr server reload-config`、それでも駄目なら `herdr server stop` のうえで再接続する。
- `herdr worktree open --help` が `unknown option: --help` を返す
  → 末端のサブコマンドはヘルプを持たないものがある。`herdr worktree --help` に usage 行がまとまっている。
- `herdr wait agent-status` がタイムアウトする
  → エッジトリガなので発火を逃した可能性がある。`herdr agent list` を読み直して現在の状態を確かめる。
- エージェントが `herdr agent list` に出ない
  → 検出フックが入っていない。`herdr integration status` を見て、`herdr integration install claude` を実行する。
- エージェント名で送った指示が別のセッションへ届いた
  → 名前は herdr インスタンス全体で解決される。`herdr agent list` で衝突を確認し、リポジトリ名を前置して付け直す。
- ペインに送った指示が途中で切れて実行された
  → 指示文に改行が入っている。一行にまとめて送り直す。
- workspace を閉じても worktree が残る
  → 所有者が違う。worktree は `bonsai remove <branch>` で消す。`herdr worktree remove` は使わない。
