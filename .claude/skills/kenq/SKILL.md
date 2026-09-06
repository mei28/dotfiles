---
name: kenq
description: 研究の claim を立てて論文にするまでの規範。claim の反証可能性と価値の点検、トピックセンテンスによる骨子、既知から未知への語順、図表、実験の論理と再現性、投稿前点検を、段階ごとに参照ファイルへ振り分ける。研究のアイデアを詰めるとき、論文の骨子や本文を書くとき、日本語原稿を英語にするとき、投稿前に点検するとき、学位論文を書くときに使用する。HCI を主戦場とし、機械学習、データマイニング、ロボティクスを副次の投稿先として想定する。
---

# kenq

研究とは、新しい **claim** を提示し、それを立証することである。
claim が一文で書けるまで、本文を書き始めない。

## 段階と参照先

いま何をしているかで、読むファイルを決める。どの段階でも、先に claim シートを読む。

| していること | 読む |
|---|---|
| 研究のアイデアを詰める | `references/research.md` |
| 骨子を作る | `references/outline.md` |
| 日本語で本文を書く、推敲する | `references/outline.md`、`references/prose.md` |
| 日本語原稿を英語にする | `references/prose.md` |
| 図表を作る、直す | `references/figures.md` |
| 実験を設計する、結果を書く | `references/evidence.md` |
| 投稿前に点検する | `references/submission.md`、`references/figures.md`、`references/evidence.md` |
| 学位論文を書く | `references/outline.md` の「学位論文」節 |

## claim シート

claim シートを `.tmp/claim.md` に置く。無ければ最初に作る。
研究を進める間も書いている間も、これが唯一の参照点である。

段落を書くたびに、そのトピックセンテンスがシートのどのサブメッセージを支えているかを言えるか確かめる。
言えない段落は、claim に貢献していないか、シートのほうが古い。

```markdown
# claim

<反証可能な一文。「X は Z において Y に効く」の形に収まるか確かめる>

## 反証条件

<この claim が偽なら、何を観測すればそう分かるか。答えられなければ claim になっていない>

## 価値

<誰の何が変わるか。金額、時間、人数、精度など、見積もれるなら数値で>

## 先行研究との差

<誰のどの主張を否定するか、または拡張するか>

## サブメッセージ

| # | サブメッセージ | 支える根拠 | 状態 |
|---|---|---|---|
| 1 | | | 未着手 |
| 2 | | | 進行中 |
| 3 | | | 立証済 |

## 崩れた仮説

<検証して否定されたもの。捨てずに残す。ストーリーラインを組み直す材料になる>
```

シートは研究が進むと変わる。変わってよい。
立証したい主張がない状態で手だけ動かすことを避けるための道具である。

## 進め方

claim と骨子のトピックセンテンスは、一問一答で決める。
候補を出すのは Claude の仕事だが、確定するのはユーザーである。
一度に一つだけ問い、答えを聞いてから次を決める。この作法は `../grill-me/SKILL.md` に従う。
ただし問う軸は grill-me の決定木ではなく、`references/research.md` と `references/outline.md` が持つ固定の軸である。

本文の下書きはユーザーが日本語で書き、Claude は点検と推敲に徹する。
ユーザーが明示的に頼んだときだけ、Claude が本文を下書きする。英語化はこの制限の外にある。

この配分には理由がある。
AI は文章をそれらしく整えるのは得意だが、元の論理やストーリーが崩れていると綺麗には直せない。
ネイティブチェックでも表面的な誤りは直るが、論理とパラグラフ構成は改善しない。
骨組みを作る工程を渡すと、直せない崩れを抱えたまま先へ進むことになる。

## 併用する規範

- 日本語原稿の文と段落: `../japanese-tech-writing/SKILL.md`
- 英語原稿の文と段落: `../tech-writing/SKILL.md`
- 通して読ませたい章（学位論文の序論など）: `../cognitive-rhythm-writing/SKILL.md`

`references/prose.md` はこれらと重複しない。論文に固有の差分だけを持つ。

## 出典

一次情報にあたるための索引である。規範の由来を確かめたいときに使う。

| 出典 | 反映先 |
|---|---|
| 暦本純一「よい論文の書き方」<https://rkmt.hatenadiary.org/entry/20101215/1292374172> | research、outline、figures、submission |
| 暦本純一「修論(D論)参考」<https://rkmt.hatenadiary.org/entry/20101217/1292573279> | outline、prose、submission |
| 「研究法（Claim とは）」<https://www.slideshare.net/slideshow/claim-62836813/62836813> | research |
| 安宅和人「圧倒的に生産性の高い研究者の研究スタイル」<https://kaz-ataka.hatenablog.com/entry/20081018/1224287687> | research |
| 森畑明昌「研究メモ」<https://www.graco.c.u-tokyo.ac.jp/labs/morihata/research_memo.htm> | research、outline |
| shunk031「先生の『まずは論文の骨子を箇条書きで書いてみて』に対応する」<https://shunk031.hatenablog.com/entry/lets-write-outline> | outline |
| 名古屋大学「パラグラフ・ライティング」<https://web.cshe.nagoya-u.ac.jp/asg/writing03.html> | outline、prose |
| 金田礼人「ハードウェア研究で国際トップ会議を目指す」<https://speakerdeck.com/ayatokanada/hadowea-kenkyuu-de-kokusai-toppu-kaigi-o-mezasu-iros-2027-deno-ronbun-saitaku-o-mezashi-te> | prose、research |
| 谷合竜典「伝わる論文」<https://note.com/taniai_phd/n/n36c4bd27fdeb> | submission |
| 山本和彦「正確な文章の書き方」<https://www.mew.org/~kazu/doc/japanese.html> | prose |
| Eamonn Keogh, How to do good research, get it published in SIGKDD and get it cited (SIGKDD 2009) <https://www.cs.ucr.edu/~eamonn/Keogh_SIGKDD09_tutorial.pdf> | 全ファイル |

HCI の被験者実験に固有の規範（被験者数の根拠、参加者間と参加者内の計画、統計検定の選択、質的データの扱い、倫理審査）は、上記の出典に含まれないため、このスキルは扱わない。
