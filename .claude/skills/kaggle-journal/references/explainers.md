# Picture explainers

A one-page picture that gives the user a mental model of a new method or term before the details.
The level comes from `CLAUDE.md` "Language and audience" (ELI18 by default: terms of art, formulas,
the real CV numbers, and the limits of the approximation; Japanese with English sub-labels).

## When

- A new method or a new term landed since the last wrap-up: put one line in the wrap-up plan
  (`explainer: <name>`). The user can drop it there.
- The user asks for one (図解, eli18, or a lower level such as ELI5).
- Not for variants that changed nothing or experiments that did not work, unless asked.

## The page

- File: `docs/explainers/<exp-or-topic>_eli18.html` (`_eli5`, `_age16` for other levels).
- One self-contained page: `width: 1200px`, inline CSS, inline SVG for diagrams, no external assets,
  so the headless render needs no network. Colors as CSS variables on `:root`.
- Layout: a title and one-line subtitle, then cards in reading order: the problem, how it works (a
  diagram), the score or formula, the CV result (a table with the views it was measured on), and the
  limits. One idea per card, short sentences, pictures larger than text.
- Charts follow the `dataviz` skill (palette and contrast).
- Every number names its source: experiment, run, and CV view.

## Render and post

1. `just explainer docs/explainers/<name>.html` writes `<name>.png` next to it, cropped to the content.
   Read the PNG before committing; fix overflow and overlapping labels in the HTML.
2. Commit the HTML and the PNG; push.
3. After the push, embed it in the idea Issue(s) it explains and in the diary comment:
   `![<name>](https://github.com/<owner>/<repo>/blob/main/docs/explainers/<name>.png?raw=true)`,
   with the source path on the line above. Several levels go in `<details>` blocks, the default
   level open.
4. When the explainer introduces terms, add them to `docs/glossary.md` in the same wrap-up.
