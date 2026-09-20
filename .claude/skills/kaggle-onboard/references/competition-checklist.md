# Competition checklist

Fill `docs/competition.md` by answering these questions. A question with no answer is an "Open
question" in the doc, not a blank.

## Platform

- Kaggle slug and URL. Team size limit and merger deadline.
- Is it a Getting Started or Playground competition (no medals, relaxed rules) or a medal competition?

## Task

- What is one row of the submission (one image, one user, one time step, one document)?
- Input modalities and sizes. Output type: class label, probability, regression value, ranking,
  segmentation mask, text, agent action.
- Number of classes or the target range. Class balance.

## Data

- Files and their sizes. Which columns join train, test, and auxiliary tables.
- How the host split train from test: random rows, by group (user, patient, site), by time. This
  decides the fold strategy in `kaggle-validation`.
- Hidden test set size (code competitions often reveal only a sample). Public/private LB fraction.
- External data and pretrained models: allowed, restricted, or forbidden.

## Metric

- Official name and the exact formula from the evaluation page.
- Averaging (macro, micro, weighted, per row then mean), thresholds, how ties and missing classes
  are treated, clipping of probabilities.
- Whether it rewards calibration (log loss) or ranking (AUC) or a threshold (F1, accuracy).
- The `kgl.metrics` name and the hand-computed test that pins it.

## Submission

- CSV competition: file name, columns, id order, dtype of the prediction column, value range.
- Code competition: notebook runtime limit (CPU and GPU), GPU type, internet off, whether the test
  set is served in batches through an API, which datasets or models can be attached, wheel handling
  for dependencies.
- Submissions per day and how many count at the end (usually two).

## Timeline

- Start, entry deadline, team merger deadline, final submission deadline (with time zone).
- 30% and 70% marks computed from start and deadline. These drive the phase guard.

## Rules

- Hand labeling, use of test data for training, model licensing, sharing outside the team.
- Anything unusual (efficiency prizes, reproducibility requirements, write-up requirements).

## Simulation competitions

- Engine (`kaggle_environments` name or custom), how to reproduce an episode locally.
- Agent interface (`def agent(observation, configuration)`), return format, per-move time and memory
  limits, agent file size limit.
- There is no fixed CV: the proxy is the win rate against a versioned pool of opponents.
