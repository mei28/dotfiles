# Tracking Issues

`kaggle-onboard` creates these three Issues once per competition, with the approval of its first
Issues. Bodies follow `CLAUDE.md` "Language and audience" (English, then `## 日本語訳`), except the
Glossary, whose body is the glossary file.

## Diary

- Title: `Kaggle 日記 / Diary`
- Label: `log`. Pin it: `gh issue pin <n>`.

```markdown
A running log for the whole competition: one comment per wrap-up (the kaggle-journal skill),
headed by its date, day number, and phase. Anything that grows moves out, and the diary keeps a link.
- An idea to test becomes its own `idea` Issue.
- A fact that later decisions depend on goes into `docs/*.md`.

The proposed order of work and the decisions waiting for the user live in `docs/roadmap.md`.

---

## 日本語訳

コンペ全体を通した作業日記。一括更新のたびにコメントを 1 つ足し、先頭に日付、何日目か、フェーズを書く。
大きくなったものは日記から移し、日記には移した先へのリンクを残す。
- 試す案は `idea` の Issue にする。
- あとの判断が依存する事実は `docs/*.md` に書く。

作業の順序の提案と、ユーザーが決めることは `docs/roadmap.md` にある。
```

## Glossary

- Title: `用語集 / Glossary`
- No label. Pin it: `gh issue pin <n>`.
- Body: `gh issue create --title "用語集 / Glossary" --body-file docs/glossary.md`, then
  `gh issue edit <n> --body-file docs/glossary.md` on every change.
- An ELI18 picture of the glossary, when the user asks for one, goes in a comment, not in the body.

## CV vs LB

- Title: `CV vs public LB`
- Label: `cv`. Not pinned (GitHub pins at most three Issues; the third slot stays free).
- The figure is `docs/figures/cv_lb.png` from `just cv-lb-plot`. Until the first LB exists, the body
  holds the first two paragraphs without the image.

```markdown
Tracking issue for how the CV predicts the public LB. After every scored submission the figure is
regenerated with `just cv-lb-plot` (reads `docs/submissions.md`) and this body is updated.

![CV vs public LB](https://github.com/<owner>/<repo>/blob/main/docs/figures/cv_lb.png?raw=true)

- x: the CV of the submitted run; y: its public LB. The dashed line is CV = LB.
- Color: submission order, light = older. Grey segments join consecutive submissions.

## Notes

- YYYY-MM-DD: <exp> left the line (CV ..., LB ...); <why, with a link to the Issue or doc>.

---

## 日本語訳

<the same headings and notes in Japanese>
```

Notes are dated and newest last. Write one when a submission moved away from the line by more than
the LB noise (public LB size and the metric decide it; write the noise down once in
`docs/validation.md`), or when the reading of the CV changed. A competition-specific figure (a proxy
CV on another scale than the LB) replaces `tools/cv_lb_plot.py` in that repository; update the legend
to match.
