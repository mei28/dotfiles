# 機械 lint の手順と指摘の扱い

textlint と suiko で日本語の原稿を検査し、指摘を一つずつ「直した」か「残す（理由）」に仕分ける。指摘は候補であって命令ではない。機械にやらせるのは網羅で、直すかどうかの判断は文脈を読んで決める。

## 必要なツール

`scripts/lint.sh` は PATH 上の実行ファイルを呼ぶだけで、無ければエラーで止まる。導入は nix home-manager の `.config/nix/home-manager/modules/ja-lint.nix`（`profiles/base.nix` から読むので全ホスト共通）で、`just update <host>` で入る。

| ツール | 版 | 由来 | 用途 |
|---|---|---|---|
| `suiko` | 0.3.8 | `.config/nix/pkgs/suiko.nix`（GitHub release のビルド済みバイナリ） | 翻訳調、反復、文長、文書構造、読解負荷 |
| `textlint` | 15.8.0 | `.config/nix/pkgs/textlint-ja/`（`buildNpmPackage`。下の 2 プリセットを同梱し、`--rules-base-directory` を焼き込んだ wrapper） | 2 プリセットの実行系 |
| `textlint-rule-preset-ai-words-ja` | 1.2.1 | 同上 | AI 以後に増えた語 55 語、短い主題の読点 |
| `@textlint-ja/textlint-rule-preset-ai-writing` | 1.7.0 | 同上 | 太字ラベル付き箇条書き、誇張語、強調の型、コロン接続、技術文書の言い回し |
| `pandoc` | nixpkgs | `pkgs.pandoc` | `.tex` を Markdown に変換する |

nix の `textlint` は同梱の 2 プリセット専用で、他のルールは解決しない。版を上げるときは、suiko は `suiko.nix` の `version` と 4 つの hash（release の `.sha256` を `nix hash convert --hash-algo sha256 --to sri` で変換）、textlint は `package.json` を直して `npm install --package-lock-only --ignore-scripts` でロックを作り直し、`nix run nixpkgs#prefetch-npm-deps -- package-lock.json` で `npmDepsHash` を差し替える。`nix build .#suiko` と `nix build .#textlint-ja` で単体確認できる。

nix を使えない環境では手動で入れる。textlint はプリセットを設定ファイルの位置からは解決しないので、3 パッケージを同じ prefix に入れる（`npm i -g textlint@15.8.0 textlint-rule-preset-ai-words-ja@1.2.1 @textlint-ja/textlint-rule-preset-ai-writing@1.7.0`）。suiko は `cargo install suiko --locked`（Rust 1.97 以上）かビルド済みバイナリ。二重に入れない。PATH では `~/.cargo/bin` と `~/.npm-global/bin` が `~/.nix-profile/bin` より先に来るので、手動導入分が残っていると nix 側は使われない。

## いつ実行するか

日本語の散文をファイルに書き出して人に渡すとき。原稿、論文本文、共有する文書、`.tmp/*.md` の設計メモが対象で、チャットの返答と handoff の `.tmp/progress.md` は対象外。kenq でユーザーの原稿を推敲したときは、直した後の版にかける。ユーザーが書いた文に出た指摘も区別せず、同じ基準で判断する。

## 実行

```sh
~/.claude/skills/japanese-tech-writing/scripts/lint.sh <file>...
~/.claude/skills/japanese-tech-writing/scripts/lint.sh --genre essay <file>   # 読み物のときだけ
```

`just ja-lint <file>...` でも同じ。受け付けるのは `.md` `.markdown` `.txt` `.tex`。設定は `.textlintrc.json` と `.suiko.toml` の一つずつで、ジャンル別の許可リストは持たない。`--genre` を省くと `.suiko.toml` の `tech` が使われる。

`.tex` は pandoc で Markdown に変換した一時ファイルに検査をかける。日本語文末の半角「.」「, 」と全角「．」「，」は「。」「、」に直してから渡す。suiko の文分割が `。！？` しか見ないためで、直さないと段落全体が一文と数えられて文長と反復の指摘が壊れる。元ファイルは変更しない。指摘の行番号は変換後のファイルのものなので、抜粋で元の箇所を探す。

ツールが無いとき、スクリプトは `not found on PATH` で止まる。導入してから続ける。目視の点検で代用しない。

## 出力の読み方

textlint は `path:line:col: message [Warning/ruleId]` の一行形式で出る。ruleId は `ai-words-ja/no-ai-words`、`ai-words-ja/no-short-topic-comma`、`@textlint-ja/ai-writing/<rule>` のいずれか。全ルールを severity `warning` に固定してあるのは、`error` の指摘があると textlint が exit 1 を返し、指摘と実行エラーを区別できなくなるからで、重みの違いではない。

suiko は件数、カテゴリ別の内訳、`[warn] L12 (category)` に続く該当箇所と説明、最後に読解負荷のブロックを出す。読解負荷（長い一文、読点のない長文、漢字の連続、二重否定、「の」の連鎖、長い連体修飾節）は AI 臭とは別の観点で、既存の規範「読み手の負荷の管理」に従って直す。

同じ箇所を両ツールが指すことがある。台帳では一件として扱い、同じ修正を二度当てない。重なるのは、suiko の `bullet_bold_label` / `hype_expression` と textlint の `no-ai-list-formatting` / `no-ai-hype-expressions`、suiko の `translationese` と textlint の `ai-tech-writing-guideline`（「〜することができる」）、`short_topic_comma` と `no-short-topic-comma`。

定義の箇条書き `**用語**：説明` は本スキルの整形規範が指示する形だが、textlint の `no-ai-list-formatting` はこれを太字ラベルとして指す。「残す/規範上の指示」で記録する。

## 判断台帳

指摘ごとに一行、チャットの返答に書く。ファイルにはしない。当面は全件を見せ、慣れてきたら「残す」だけに減らす。

```
- [直した] no-ai-words「入口」: 「最初の一歩」に言い換えた
- [直した] antithesis_repetition: 4 箇所のうち 3 箇所を肯定文にした
- [残す/字義どおり] no-ai-words「検査」: 製造工程の検査を指す
- [残す/術語] translationese「〜することができる」: API 仕様の可能表現として正確さを優先
- [残す/規範上の指示] no-ai-list-formatting: 定義の箇条書き
```

理由の種類は、固有名詞、術語、字義どおり、文脈上必要、ジャンル上自然、規範上の指示。理由のない「残す」は書かない。

## 収束

出口は二つそろったときだけ。台帳の全指摘が仕分け済みで、かつ直した結果を再実行しても新しい指摘が出ない。直したら必ず再実行する。

同じ指摘が二周続けて再発したら、その一文の言い換えを重ねない。段落の構造から書き直すか、理由を付けて残す。

## 一律に直さない

既にある文書を直すとき、同じ種類の修正を全箇所に当てると、その均質さが新しい AI 臭になる。着手前に節ごとに keep / change を割り振り、既定は keep にする。change にするのは、直すことで読者の得が具体的に言える箇所だけ。口語のままの引用、矢印や略記、節ごとの不揃いは人が書いた痕跡であり、読解を妨げていない限り整えない。元文書が未決のまま置いている論点に、著者の見解を書き足さない。

## 信号の信頼度

suiko と natural-japanese のコーパス比較（人間 103 文書、AI 81 文書）で弁別力が確かめられた順に並べる。

- 最も強い: `low_burstiness`（文長のメリハリがない）。AI 86% に対し人間 8〜16%。ただし人間の技術文書でも約 3 割が発火する。
- 通常: `forbidden_phrase`、`translationese`、`antithesis_repetition`（一致数が総文数の 2% 以上で warn）、`inanimate_subject_morph`、`abstract_metaphor`。
- 実験的（`--experimental`、`lint.sh` は常に付ける）: 太字密度、箇条書き比率、「まとめ」見出し、短い主題の読点、技術比喩（静かに壊れる、地味に効く、時間を溶かす、安全側に倒す）、節頭の予告の反復、体言止めの連続。Qiita の比較で動いた文書レベルの信号はここにしか無いので有効にしてある。校正は弱く、自然な文にも当たる。
- 無効化: `nominal_ending`（体言止めがゼロだと疑う反転検出器で、本スキルの規範と衝突する）、`repeated_sentence_lead`（人間文書の 61% で発火）、`low_lexical_diversity_ttr`（文書長に依存）、`low_lexical_diversity_mtld`（どの閾値でも AI を検出しなかった）。理由は `.suiko.toml` にも書いてある。

信号ではないもの。「最後に」（人間 48 回、AI 2 回）と「まさに」（人間 24 回、AI 0 回）は人間側に多い日常語で、削っても AI 臭は減らない。連体修飾の入れ子の個数は人間文書の 85% で発火し弁別力がない。感嘆符と文頭の「また、」は AI 以後に減った側で、足しても引いても変わらない。

## 根拠

語彙の増加倍率は、Qiita の記事 7 万本を生成 AI 以前（2019〜2022 年）と 2026 年で比べた分析による。出現率の変化の例: 効く 2.0%→22.3%、〜した瞬間 0.9%→13.7%、実測 0.1%→7.2%、既定 0.5%→7.1%、入口 0.4%→6.8%、事故 0.3%→6.8%、疑う 0.5%→6.3%、土台 0.3%→5.5%、別物 0.4%→5.5%、切り分ける 0.5%→5.2%、混ざる 0.4%→4.9%、静かに壊れる 0.1%→4.9%、照合 0.3%→4.5%、潰す 0.3%→4.2%、見落とす 0.3%→4.1%、道具 0.3%→4.1%、落とし穴 0.3%→4.0%、定番 0.5%→3.6%、黙って捨てられる 0.1%→3.4%、要点 0.5%→3.2%、踏み込む 0.3%→2.7%、核心 0.07%→2.4%、定石 0.1%→1.8%。文書の形では、太字が 1,000 字あたり 1.26→3.83、箇条書きの割合 8.9%→16.4%、文中ダッシュ 0.043→0.426、「まとめ」見出し 12%→52%、です・ます 50%→66%、一文あたりの読点 0.63→0.95、漢字率 19%→24%。

これらは「AI 以後に増えた」であって「AI が書いた証拠」ではない。分析自体が、AI の影響と人間の模倣を区別できていないと注記している。

## 個人辞書に語を足す

嫌な語に気づいたら `ai-words.user.json` に項目を足し、`ai-vocabulary.md` の「Claude 自身の癖」に行を足す。辞書の形式はプリセットと同じで、`tokens` に kuromoji の品詞と基本形を並べる。一語が複数の形態素に割れるときは `surface_form` の列で書く。分割は次で確かめられる。

```sh
node -e 'require("kuromojin").tokenize("腑分けする").then(t=>console.log(t.map(x=>[x.surface_form,x.pos,x.basic_form])))'
```

## 前回との比較（任意）

```sh
suiko lint --config ~/.claude/skills/japanese-tech-writing/.suiko.toml --experimental --json <file> > "$TMPDIR/before.json"
suiko lint --config ~/.claude/skills/japanese-tech-writing/.suiko.toml --experimental --json --baseline "$TMPDIR/before.json" <file>
```

指摘が resolved / new / persisting に分かれる。作業ファイルはスクラッチパッドか一時ディレクトリに置き、終わったら消す。

## 出典と更新の確認先

取り込んだ元と、その時点の版。上流が更新されたら、右の欄のファイルに反映する。

| 元 | URL | 取り込んだもの（2026-09-19 時点） | 更新時に見直す先 |
|---|---|---|---|
| nwiizo/suiko | https://github.com/nwiizo/suiko （crates.io: https://crates.io/crates/suiko ） | CLI 0.3.8（nix、GitHub release）。`skills/suiko/references/` の translationese.md、forbidden-patterns.md、revision-guide.md、readability-antipatterns.md、`eval/technical-wording.md`、`eval/calibration.md`。CHANGELOG は https://github.com/nwiizo/suiko/blob/main/CHANGELOG.md | 新しい検出カテゴリは `ai-syntax.md` の表と `.suiko.toml` の `disabled_rules`。版は `.config/nix/pkgs/suiko.nix`。校正結果の変化は本ファイルの「信号の信頼度」 |
| coji/natural-japanese | https://github.com/coji/natural-japanese | suiko の元。references は同一。判断台帳とスイープ改稿の罠は `skills/natural-japanese/references/revision-guide.md` | 本ファイルの「判断台帳」「一律に直さない」 |
| p1ass/textlint-rule-preset-ai-words-ja | https://github.com/p1ass/textlint-rule-preset-ai-words-ja （npm: https://www.npmjs.com/package/textlint-rule-preset-ai-words-ja ） | 1.2.1。辞書 55 語（README の「検出する単語」表、`src/dictionary.ts`）、`no-short-topic-comma` | 語の追加・削除は `ai-vocabulary.md` の表。`.textlintrc.json` のオプション。版は `.config/nix/pkgs/textlint-ja/package.json` |
| textlint-ja/textlint-rule-preset-ai-writing | https://github.com/textlint-ja/textlint-rule-preset-ai-writing （npm: https://www.npmjs.com/package/@textlint-ja/textlint-rule-preset-ai-writing ） | 1.7.0。5 ルール（no-ai-list-formatting、no-ai-hype-expressions、no-ai-emphasis-patterns、no-ai-colon-continuation、ai-tech-writing-guideline） | ルールの追加は `.textlintrc.json`（severity を warning で明記する）。版は `.config/nix/pkgs/textlint-ja/package.json` |
| textlint | https://github.com/textlint/textlint | 15.8.0。`--config`、`--format unix`、`--rules-base-directory` の挙動 | 本ファイルの「必要なツール」の版 |
| Qiita 7 万記事の前後比較（nyosegawa） | https://nyosegawa.com/posts/qiita-writing-before-after-ai/ | 語彙の増加倍率、文書の形の変化（本ファイルの「根拠」） | 数値は「根拠」節、語の一覧は `ai-vocabulary.md` |
| k16shikano「日本語技術文書の文章規範」 | https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d | `SKILL.md` の「LLM っぽい表現の禁止」の元。suiko / natural-japanese も同じ gist を取り込んでいる | `SKILL.md` の同節 |

MIT の表示は `third-party-notices.md` にある。
