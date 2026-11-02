# humanizer の取り込み記録

imos（今城健太郎）さんの推敲ルール humanizer を、このスキルと tech-writing へ取り込んだ記録である。
上流が更新されたか確かめるときと、ある規則の由来を調べるときに読む。

## 取り込んだ版

| ファイル | URL | sha256 | Last-Modified |
|---|---|---|---|
| 日本語版 | <https://imoz.jp/humanizer.ja.txt> | `752848e2eda3d58c0602c8a2e46da0c1d41a6a622af15cbf9f1e339cdef22dde` | 2026-11-02 05:29 GMT |
| 英語版 | <https://imoz.jp/humanizer.en.txt> | `bf330d6de5d0185673a97a54cfb91a8e816666b929e93fcf35f39cbafe8cf157` | 2026-11-02 05:29 GMT |
| 紹介記事 | <https://imoz.jp/scraps/202610_humanizer.html> | 記録しない | |

取得日は 2026-11-02 である。
上流にライセンスの記載がなく、dotfiles は public なので、文言も例も転載していない。
規則は一つずつ自分の言葉で書き直し、条件と強さを保った。
例はすべて作り直した。
上流の旧版はリポジトリにも手元にも保存していない。

上流と食い違う形で取り込んだ規則がある。
既存の規範との衝突を、読者の得で一件ずつ決めた結果である。
決めた内容は、各規則の書かれた位置に反映してある（体言止めの禁止を残した、読点を打つ理由を本多の四つに限ったまま残した、など）。
英語の自称の規則（"the author" と書かず I と my を使う）には、既存の文書を推敲するときは今の自称を変えない、という条件を足した。
2026-11-02 の試しで、この規則が既存の README の "the author" を "I" に書き換えたためである。

## 更新を確かめる手順

ユーザーに聞かれたときに、手で行う。

1. 上の 2 ファイルを取得し、sha256 を求める。
2. 表の値と同じなら終える。
3. 違えば、上流の見出しの一覧を下の対応表と比べ、足された節、消えた節、名前の変わった節を探す。
4. 中身が変わった節は、上流の該当する節と、対応表の反映先の規則を読み比べる。旧版は保存していないので、差分は今の規範との比較で見つける。インターネットアーカイブ（<https://web.archive.org/>）に旧版が残っていれば、それと比べてもよい。
5. 反映したら、sha256、Last-Modified、取得日を、規則の変更と同じ commit で更新する。

## 日本語版の対応表

反映先のパスは `japanese-tech-writing/` から見た位置で書く。

| 上流の見出し | 反映先 |
|---|---|
| 前文 | `SKILL.md` 冒頭（依頼と媒体の指定、読みにくさの原因、検出器の点数）、`references/lint.md` 冒頭 |
| 読者と記事の目的 | `references/composition.md`「読者と到達点」、`SKILL.md`「段落と論証の構成」の最初の項。日英の記事の段落は `references/genres.md`「日英の両方で書く記事」 |
| 文体と主張の強さ（前文） | `SKILL.md`「視点と語り」（文体、文体の見本、一人称、「本記事では」） |
| 断定と推測の書き分け | `references/claims.md`「断定と推測」、`SKILL.md`「論証の厳密さ」（観測・仮説・原因・目的の区別、「〜と考えられる」） |
| 留保と適用条件 | `references/claims.md`「留保と適用条件」、`SKILL.md`「段落と論証の構成」（先回りの否定の条件） |
| 文・段落の作り方 | 見出しだけ |
| 見出しの書き方 | `SKILL.md`「見出しの付け方」 |
| 文の長さと段落の区切り | `references/sentence.md`「読点」「文の組み立て」（文の長さの目安）、`SKILL.md`「段落と論証の構成」（一文だけの段落）、`SKILL.md`「冗長の排除」（まとめるときの確かめ方、総括文）、`references/composition.md`「説明の順序と分量」 |
| 文末の意味と文型の反復 | `references/sentence.md`「文末と時制」、`SKILL.md`「冗長の排除」（同じ文型の反復） |
| 概要・詳細・まとめの役割分担 | `references/composition.md`「導入・各節・まとめの分担」 |
| 問題意識と提案の位置づけ | `references/composition.md`「取り上げる理由と既存の方法」 |
| 段落のつなぎ方 | `SKILL.md`「段落と論証の構成」（接続詞、挙げた順と説明する順）、`SKILL.md`「演出の抑制」（重要さだけを述べる文）、`references/composition.md`「案内文と行動を述べる文」、`references/ai-syntax.md`（重要性だけを述べる文の行） |
| 説明と根拠 | 見出しだけ |
| 理由・条件を伴う説明 | `references/claims.md`「評価と理由」 |
| 主張と根拠の対応 | `references/claims.md`「主張と根拠の対応」、`SKILL.md`「読者への誠実さ」、`references/revision.md`「出典を確かめられない主張」 |
| 具体例による理解 | `references/composition.md`「例の選び方と引き継ぎ」 |
| 対象・操作・結果の説明 | `references/composition.md`「対象・操作・結果」 |
| 言い換えで保つ意味 | `references/revision.md`「言い換えで保つ意味」、`SKILL.md`「冗長の排除」（短さだけを改善の理由にしない）、`SKILL.md`「演出の抑制」（指示の強さ） |
| 文の構造 | `references/sentence.md`「文の組み立て」 |
| 既存の方法・製品との比較 | `references/claims.md`「比較」 |
| 数値の出所と精度 | `references/claims.md`「数値の出所と精度」（設定値の行は英語版から足した） |
| 語彙の選び方 | `references/terms.md`「語の組み合わせ」、`references/ai-vocabulary.md` 冒頭 |
| 平易な評価表現 | `references/terms.md`「評価の言葉」 |
| 用語の意味と導入 | `references/terms.md`「用語の導入と定義」 |
| 表記と強調 | `references/sentence.md`「表記」、`SKILL.md`「演出の抑制」（太字とコードの書式）、`SKILL.md`「整形」（箇条書きのラベル）。読点の規則は `references/sentence.md`「読点」の本多の四つの理由で扱う |
| 記事の種類に応じた構成 | `references/genres.md` 冒頭 |
| レビュー・実用記事 | `references/genres.md`「レビュー・実用記事」 |
| 調査型まとめ・比較記事 | `references/genres.md`「比較のまとめ記事」 |
| 技術解説・手順 | `references/genres.md`「技術解説・手順」 |
| 数理・理論記事 | `references/genres.md`「数理・理論記事」 |
| 技術仕様・定義 | `references/genres.md`「技術仕様・定義」 |
| 調査・試算記事 | `references/genres.md`「調査・試算記事」 |
| 本文・補足・図表 | `references/notes-figures.md` 冒頭と「本文と補足の分担」 |
| 本文と補足の役割分担 | `references/notes-figures.md`「本文と補足の分担」 |
| 図表とキャプション | `references/notes-figures.md`「図表とキャプション」 |
| 表とリストの選び方 | `references/notes-figures.md`「表とリストの選び方」 |
| 検索を使った確認 | `references/revision.md`「数えることと検索」、`references/lint.md` 冒頭 |
| 執筆後の確認事項 | `references/revision.md`（対象と範囲、点検の 6 段階、渡す前の確認、終える条件） |

## 英語版の対応表

反映先のパスは `tech-writing/` から見た位置で書く。
推敲の手順は日英で共通にし、`japanese-tech-writing/references/revision.md` に置いた。

| 上流の見出し | 反映先 |
|---|---|
| # Writing and editing English articles | `SKILL.md` 冒頭の 2 段落目 |
| ## Readers and purpose | `references/structure.md`「Readers and purpose」 |
| ## Requirements, defaults, and article choices | `references/structure.md`「Requirements, defaults, and document choices」。AI っぽさを扱う段落は `SKILL.md`「Symptoms」の冒頭 |
| ## Content selection | `references/structure.md`「Content selection」 |
| ## Article patterns | `references/genres.md`「Document patterns」 |
| ## Translating and synchronizing articles（3 つの ### を含む） | `references/genres.md`「Translation and synchronization」と、その下の 3 つの ###。冒頭に、論文では kenq が優先すると書いた |
| ## Voice and point of view | `references/sentences.md`「Voice, person, and self-reference」。文体と縮約形は `SKILL.md`「Sentences」、個人レビューは `references/genres.md`「Personal reviews」、体験を作らない規則は `SKILL.md`「Claims」、判断の理由と開示は `references/claims.md`「Judgments, disclosures, and editing work」 |
| ## Sentences, paragraphs, and connections | 見出しだけ |
| ### Organize around the reader's next question | `references/structure.md`「Organizing around the reader's next question」。ラベルとリストの段落は `SKILL.md`「Lists」と `references/structure.md`「Tables, lists, or paragraphs」 |
| ### Make relationships explicit | `references/sentences.md`「Making relationships explicit」。受動態の条件は `SKILL.md`「Sentences」 |
| ### Revise rhythm through meaning | `references/sentences.md`「Rhythm through meaning」。一文一義の定義は `SKILL.md`「Sentences」 |
| ### Remove padding while preserving meaning | 文の水準は `references/sentences.md`「Removing padding while preserving meaning」、節の水準は `references/structure.md`「Repetition, recaps, and section endings」。締めの要約は `SKILL.md`「Structure」 |
| ### Use headings that explain the section's purpose | `references/structure.md`「Heading patterns」、`SKILL.md`「Structure」（役割見出し） |
| ## Terminology and definitions | `references/sentences.md`「Terminology and definitions」「Word combinations」「Articles, number, and quantifiers」 |
| ## Technical reasoning and strength of claims | `references/claims.md`「Results, examples, and supporting numbers」 |
| ### Explain quantities and calculations | `references/claims.md`「Quantities and calculations」 |
| ### State interpretations at the strength the evidence supports | `references/claims.md`「Interpretations at the strength the evidence supports」「Sources and attribution」。未確認の主張は `SKILL.md` の点検手順 2 と「Revising」 |
| ### Support recommendations | 時点は `references/claims.md`「Recommendations and time points」、価格と選定基準とアフィリエイトは `references/genres.md`「Prices, selection criteria, and affiliate links」 |
| ### Avoid defensive qualifications | `references/claims.md`「Defensive qualifications」 |
| ## Main text, notes, and captions | `references/structure.md`「Main text, notes, and captions」「Alt text」。開閉式の注は `references/genres.md`「Collapsible notes」、図のラベルと UI の翻訳は `references/genres.md`「Interface labels and other translated text」 |
| ### Choosing tables or lists | `references/structure.md`「Tables, lists, or paragraphs」 |
| ## English notation and local context | `references/sentences.md`「English notation and local context」（日付の規則に ISO 8601 の例を足した） |
| ## Editing and review | `japanese-tech-writing/references/revision.md`（日英共通の手順と「英語の文書」の節）。`SKILL.md`「Revising」に 4 つの義務と終える条件、「Symptoms」に数えることの原則、点検手順 6 に応答の文の除去 |
