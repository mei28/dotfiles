# org-mode helpers. Sourced from .bashrc.
# Files live in ~/org; the nvim side is .config/nvim/lua/plugin/orgmode.lua
# Run `oh` for the full cheatsheet.
#
# Same shape as ot/obm in .bashrc, but writes to ~/org/journal instead of the
# Obsidian vault. Kept separate so ot/obm keep working unchanged.

function createOrgDailyFileIfNeeded() {
    local target_dir="$HOME/org/journal"
    local today=$(date +"%Y-%m-%d")
    local file_path="$target_dir/$today.org"

    mkdir -p "$target_dir"

    if [ ! -f "$file_path" ]; then
        printf '#+TITLE: %s\n#+FILETAGS: :journal:\n' "$(date +"%Y-%m-%d %A")" > "$file_path"
    fi
    echo "$file_path"
}

# Append a thought without opening an editor. Timestamp format matches the
# capture template's %U, so both paths produce the same file.
function om() {
    local file_path=$(createOrgDailyFileIfNeeded)
    local time_stamp=$(date +"[%Y-%m-%d %a %H:%M]")

    if ! grep -qF "$time_stamp" "$file_path"; then
        printf '\n* %s\n' "$time_stamp" >> "$file_path"
    fi

    echo "$*" >> "$file_path"
    printf '→ %s  %s\n' "~${file_path#$HOME}" "$(date +%H:%M)"
}

function oj() {
    nvim "$(createOrgDailyFileIfNeeded)" # open today's journal
}

alias org='nvim ~/org/tasks.org'
alias oi='nvim ~/org/inbox.org'

# Cheatsheet: the workflow, the commands, and the keys inside nvim.
function oh() {
    cat <<'EOM'
━━ まずこの 4 つ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  org           やることを書く / 見る
  oa            今日の締切を見る
  om <text>     思ったことを流す（エディタを開かない）
  oh            このヘルプ

━━ 何をどこに書くか ━━━━━━━━━━━━━━━━━━━━━━━━━
  判断は 1 つ「それはやることか？」
    やること        → org        tasks.org のプロジェクトの下へ
    ただの記録      → om <text>  journal（日付ごとのファイル）
    分類が決まらない → oi         inbox.org（当面は使わなくてよい）
  迷ったら om に流す。あとから org へ書き写せる。逆はできない。
  journal とタスクは自動では紐づかない。om の先頭にプロジェクト名を書いておくと
  あとで og <名前> で両方まとめて引ける（例: om TIIS 因果は言えなさそう）。

━━ 1 日の流れ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  朝    os          他の端末の変更を取り込む
        oa          今日の締切と NEXT を見る（1〜2 分）
  日中  om <text>   思いついたら流す
        org         やることを足す
  夕方  oa → t      終わったものを DONE にする
        on          日報の下書きを生成 → 直して提出
        os          その日の変更を push
  週次  ow          他人待ちを棚卸しして、止まっているものをつつく
  月次  <leader>o$  DONE をアーカイブして tasks.org を軽くする
        ol          今月やったことを振り返る

━━ コマンド ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  org           tasks.org を開く
  oa            今日の締切と NEXT
  ow            他人待ちの一覧
  ow <タグ>     任意のタグで検索（例: ow 急ぎ）
  ol [件数]     完了したものを新しい順に（既定 20 件。archive も含む）
  og <検索語>   全ファイルを横断検索（tasks も journal も。どの見出しかも出る）
  on [日付]     日報の下書きを生成（既定は今日。例: on 2026-07-29）
                標準出力のみ。保存やコピーはリダイレクトで:
                  on | pbcopy          クリップボードへ
                  on > ~/nippou.md     ファイルへ
  os            端末間の同期（pull → commit → push）
  om <text>     journal に 1 行追記
  oj            今日の journal を開く
  oi            inbox.org を開く
  oc            capture（t=times / T=times+リンク / i=inbox / n=NEXT）
  oh            このヘルプ

━━ 書き方 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  * プロジェクト名                    ← tasks.org の第 1 階層
    :PROPERTIES:
    :CATEGORY: 表示名                 ← agenda の左端に出る名前
    :END:
  ** TODO やること                          :タグ:
     DEADLINE: <2026-08-05 Wed>       ← 締切。14 日前から oa に出る
     SCHEDULED: <2026-08-01 Sat>      ← 着手予定日。その日から出続ける

  壊れる書き方（エラーが出ないので注意）
    ・行頭からでない          「  ** TODO」→ 見出しにならない
    ・* の後にスペースがない  「**TODO」  → 見出しにならない
    ・先頭が「- 」            「- やること」→ リスト項目でタスクでない
    ・DEADLINE の前に空行     → 締切として効かず先読みされない
    ・:PROPERTIES の閉じコロン忘れ
    ・タグの後ろに文字がある  → タグとして認識されない
  確認: org で開いて TODO に色が付いていれば正しい

━━ agenda の中（oa / ow） ━━━━━━━━━━━━━━━━━━━
  t             状態を回す  TODO → NEXT → WAITING → DONE
                ※ WAITING と DONE は画面から消える（消えても消滅ではない）
  <Tab>         split で開く（agenda を残す）
  <CR>          同じ窓で開く（agenda は消える）
  K             プレビューだけ
  r             再読み込み（ファイルを保存したらこれ。自動更新はしない）
  vd vw vm vy   日 / 週 / 月 / 年 表示
  b  f          前 / 次の期間        .  今日へ戻る
  R             時間集計表           q  閉じる
  g?            全キーのヘルプ

  <leader>oa でメニュー（<leader> はスペース）
    a 週の agenda   t TODO 全部   m タグ検索   s 全文検索
    d 日報ビュー    w 他人待ち

━━ org ファイルの中（org / oj / oi） ━━━━━━━━━━━
  cit  ciT      状態を進める / 戻す（u では戻せない）
                ※ 手で DONE と打つと CLOSED 時刻が入らず ol/on に出ない
  +  -          日付の上で 1 日ずらす
  <C-space>     チェックボックスを切り替え
  <Tab>         折りたたみ           <S-Tab>  全体を折りたたみ
  <leader>oit   TODO 見出しを下に挿入
  <leader>oid   締切を設定           <leader>ois  予定日を設定
  <leader>ot    タグを編集           <leader>oo   リンクを開く
  <leader>or    他のファイル/見出しへ移動（refile）
  <leader>o$    アーカイブ（tasks.org_archive へ退避）
  g?            全キーのヘルプ

━━ ファイル ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ~/org/tasks.org              やること
  ~/org/journal/YYYY-MM-DD.org 流し書き（om / oj）
  ~/org/inbox.org              分類が決まらないもの
  ~/org/tasks.org_archive      アーカイブ済み（agenda には出ない）
  ~/org は private git リポジトリ（github.com/mei28/org）。同期は os
EOM
}

# :Org is registered as a lazy.nvim cmd stub, so it resolves without loading
# orgmode up front and without going through :Lazy
alias oa='nvim -c "Org agenda d"'
alias oc='nvim -c "Org capture"'

# Completed items, newest first. nvim-orgmode has no Emacs-style agenda log mode,
# so read the CLOSED timestamps directly. They sort lexically = chronologically.
# Includes *.org_archive so archived work still shows up.
function ol() {
    awk '
      /^\*+ (DONE|CANCELLED) / { t=$0; sub(/^\*+ +(DONE|CANCELLED) +/,"",t); next }
      /CLOSED: \[/ && t != "" {
        if (match($0, /CLOSED: \[[^]]*\]/)) {
          printf "%s  %s\n", substr($0, RSTART+9, RLENGTH-10), t
        }
        t=""
      }
    ' "$HOME"/org/*.org "$HOME"/org/journal/*.org "$HOME"/org/*.org_archive 2>/dev/null \
      | sort -r | head -n "${1:-20}"
}

# Grep across every org file, showing which headline each hit belongs to.
# The agenda's full-text search (<leader>oa then s) only works interactively,
# and this also ties a journal line back to its timestamp headline.
function og() {
    if [ $# -eq 0 ]; then
        echo "usage: og <検索語>" >&2
        return 1
    fi
    awk -v pat="$*" '
      FNR==1 { f=FILENAME; sub(/.*\//,"",f); sub(/\.org.*$/,"",f) }
      /^\*+ / { h=$0; sub(/^\*+ +/,"",h) }
      /^[[:space:]]*:[A-Za-z_]+:/ { next }
      /^[[:space:]]*(DEADLINE|SCHEDULED|CLOSED):/ { next }
      /^#\+/ { next }
      $0 ~ pat {
        if ($0 ~ /^\*+ /) printf "%-12s %s\n", f, h
        else              printf "%-12s %s | %s\n", f, h, $0
      }
    ' "$HOME"/org/*.org "$HOME"/org/journal/*.org "$HOME"/org/*.org_archive 2>/dev/null
}

# Daily report draft. Fills the sections from what is already recorded:
# DONE closed today, today's journal entries, and what is still open.
# Takes an optional date (YYYY-MM-DD) to rebuild an earlier day's report.
function on() {
    local day="${1:-$(date +%Y-%m-%d)}"

    printf '## %s\n\n' "$day"

    printf '### やったこと\n'
    awk -v d="$day" '
      /^\*+ (DONE|CANCELLED) / { t=$0; sub(/^\*+ +(DONE|CANCELLED) +/,"",t); next }
      /CLOSED: \[/ && t != "" {
        if (index($0, "CLOSED: [" d)) printf "- %s\n", t
        t=""
      }
    ' "$HOME"/org/*.org "$HOME"/org/*.org_archive 2>/dev/null
    printf '\n'

    printf '### メモ\n'
    awk '
      /^\* \[/ { if (match($0, /[0-9][0-9]:[0-9][0-9]/)) tm=substr($0, RSTART, 5); next }
      /^[[:space:]]*$/ { next }
      /^#\+/ { next }
      { printf "- %s  %s\n", tm, $0 }
    ' "$HOME/org/journal/$day.org" 2>/dev/null
    printf '\n'

    printf '### 明日やること\n'
    grep -hE '^\*+ NEXT ' "$HOME"/org/*.org 2>/dev/null | sed -E 's/^\*+ +NEXT +/- /; s/[[:space:]]*:[^:]+:$//'
    printf '\n'

    printf '### 止まっていること\n'
    grep -hE '^\*+ WAITING ' "$HOME"/org/*.org 2>/dev/null | sed -E 's/^\*+ +WAITING +/- /; s/[[:space:]]*:[^:]+:$//'
}

# Sync ~/org with its private remote. Pull first so a rebase conflict surfaces
# before anything is pushed. Run it when you sit down and when you stop.
function os() {
    local dir="$HOME/org"
    git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || {
        echo "os: $dir is not a git repository" >&2
        return 1
    }

    if ! git -C "$dir" pull --rebase --autostash -q; then
        echo "os: pull で競合しました。$dir で解決してください" >&2
        echo "     解決後: git -C $dir rebase --continue" >&2
        return 1
    fi

    if [ -z "$(git -C "$dir" status --porcelain)" ]; then
        echo "os: 変更なし（remote と同期済み）"
        return 0
    fi

    git -C "$dir" add -A
    git -C "$dir" commit -q -m "notes: $(date +'%Y-%m-%d %H:%M') from $(scutil --get LocalHostName 2>/dev/null || hostname -s)"
    git -C "$dir" push -q && echo "os: 同期しました"
}

# Tag search. No argument falls back to :他人待ち:, the one worth checking weekly.
# The first -c loads orgmode through its lazy.nvim cmd stub so the API is there.
function ow() {
    if [ $# -eq 0 ]; then
        nvim -c "Org agenda w"
    else
        nvim -c "Org agenda w" -c "lua require('orgmode.api.agenda').tags({match_query=[[$*]]})"
    fi
}

