---
name: tdd
description: Test-driven development following Kent Beck's Canon TDD loop, with t_wada's step-size ladders added. Write a test list, turn exactly one item into a running test, watch it fail, make it and all previous tests pass, repeat. Use before writing or changing behavior-bearing code (features, bug fixes), and to decide when TDD does not apply.
---

# tdd

Drive implementation from a test list, one case at a time.
The goal is working clean code: make it work first, make it clean second. Never the reverse.
Restructuring (step 4 of the loop below) and all commit rules live in `../tidy-first/SKILL.md`.

## When this applies

The test is not "does this repo have a test suite" but: **can this change be stated as an assertion that fails before it and passes after it?**

TDD does not apply to these. Proceed without saying anything:
- Declarative config with no behavior of its own (Nix, YAML, editor config, dotfiles).
- Documentation, prose, comments.
- One-off scripts and exploratory spikes not meant to survive.
- Repos where the probe below finds no harness that can express the assertion.

Probe in this order: `justfile` recipes matching `test*`, then package manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Package.swift`, `Makefile`), then an existing test directory. A lint-or-build-only recipe is not a harness. `just test-all` in this dotfiles repo runs `check`, `lint-shell`, and Docker builds, none of which can assert a behavior.

Only when the change *is* testable and you are skipping TDD anyway, say so in one line with the reason, then proceed.

## The loop

Kent Beck's Canon TDD:

1. Write a list of the test scenarios you want to cover.
2. Turn exactly one item on the list into an actual, concrete, runnable test.
3. Change the code to make the test, and all previous tests, pass. Change the list as you go.
4. Optionally refactor to improve the implementation design.
5. Until the list is empty, go back to 2.

What the numbering leaves implicit:

- Between 2 and 3, run the test and watch it fail. Step 2 says **runnable**, and a test you have not run is not yet a test. See "Watching it fail" below.
- In step 3, write only enough code to pass. No extra branch, parameter, or error path that no test demands. If you want it, put it on the list instead.
- Step 3 says **and all previous tests**: run the whole suite, not only the new one.
- Step 4 says **optionally**: you do not owe a refactoring every lap.
- Changing behavior that already has a test runs the same loop: edit the test to the new expectation first, watch it fail, then change the code. That is the opposite of editing a test to match an implementation you already wrote.

## Test list

The list is behavioral analysis. It is thinking through all the different cases in which the behavior change should work, before writing any of them. Skipping it and going straight to code is the most common way TDD is misread.

- For one or two cases, keep the list in the conversation. Write `.tmp/test-list.md` when it will outlive a single exchange or another tool will pick it up. `.tmp` is gitignored, so it never reaches a commit. Point `Resume:` at it when running `handoff`.
- List behavioral variants only. Do not mix in decisions about how the internals will work.
- The first list is mostly wrong. Do not spend an hour on it; correct it as the code teaches you.
- Order matters: which test you write next changes both how the work feels and where it ends up. Start with a case simple enough to get the harness running, then take the ones you are least sure about while there is still room to change direction.
- Add a case the moment you think of it, and do not implement it then.
- Never delete a case. Mark it dropped with a reason.
- An empty list ends the phase.

```
- [ ] pending
- [~] current (already seen fail)
- [x] passing
- [-] dropped: <reason>

Current: <case>
Last seen fail: <line pasted from the runner>
```

`Last seen fail` is there for after a context compaction, when the earlier turns are gone and you need to know whether you actually watched the current case fail.

## Watching it fail

Run the test and watch it fail before writing implementation. A test you have not seen fail could already be passing, could be collecting nothing, or could be failing for a reason unrelated to the behavior you are adding. In all three cases the green that follows tells you nothing.

What matters is that it failed **for the reason the test is about**. It does not have to be an assertion failure. In a typed language, a compile or name-resolution error for the function or type this test is driving out is the correct first failure.

These are not that. Fix them before continuing:
- Zero tests collected, or the wrong file collected.
- A fixture or setup error.
- A syntax error inside the test, a missing dependency, a misconfigured runner.

Take a baseline before you start, so a pre-existing failure is not mistaken for your own. After going green, run the whole suite. If the suite is prohibitively slow or broken, say so in one line and run a narrowed selection. Never narrow it silently.

## Step size

How far you go between the test and green depends on how sure you are of the implementation. t_wada frames this as three ladders:

```
test -> fake it -> triangulate -> implement     least confident
test -> fake it -> implement
test -> obvious implementation                  most confident
```

- **Fake it**: return a hardcoded value to get green immediately.
- **Triangulate**: add a second case that the fake cannot satisfy, and let it force the general implementation.
- **Obvious implementation**: write the real thing directly. Only when you can predict the green.

```
test:        fizzbuzz(3) == "Fizz"    -> fails
fake it:     return "Fizz"            -> passes (nothing about 3 written yet)
triangulate: add fizzbuzz(1) == "1"   -> fails against the fake
implement:   branch on n % 3 == 0     -> both pass
```

Adding `fizzbuzz(6) == "Fizz"` instead would still pass against the fake, so it triangulates nothing. Pick the case that breaks the fake.

Shrink the step after any surprise, including an unpredicted **pass**. Being surprised means your model of the code is wrong, and a larger step compounds the error.

Fake it does not conflict with the no-fallback rule in `~/.claude/AGENTS.md`. It is permitted only while the hardcoded value **is** the whole implementation and the list already holds the case that will delete it. A hardcoded value sitting *beside* a real implementation, or a `try/except` returning a default, is fallback code and stays banned. Fake it is a step-size tool, never a delivery state: it must not appear in a commit presented as a finished feature.

## Defects

The order is fixed, and you end with two tests, not one:

1. Write a failing test at the API level. This shows the bug is reachable the way a caller meets it.
2. Write the smallest test that reproduces the problem. This localizes the cause.
3. Make both pass, and keep both.

Do not turn the current wrong output into the expected value. That is not a fix; it pins the bug in place.

## Mistakes

Kent Beck's interpretation errors, from Canon TDD:
- Mixing implementation design decisions into the test list.
- Writing tests with no assertions, for coverage.
- Turning every list item into a test before making any of them pass. Early tests invalidate later ones and the work is redone.
- Deleting assertions to fake a passing test.
- Copying a computed value into the expected value, which defeats the check.
- Mixing refactoring into making the test pass. The remaining refactoring errors are in `../tidy-first/SKILL.md`.

Common agent failures:
- Writing the test and the implementation in the same turn, so the failure is never seen.
- Writing several tests before running any of them.
- A new test that passes immediately, and continuing without noticing.
- Reading the implementation before writing the test, which pins the current behavior including the bug.
- Editing the test to match the implementation instead of the reverse.
- Weakening an assertion: exact match to substring, dropping a field from the expected structure, widening a tolerance.
- Accepting snapshots to force green (`-u`, `--snapshot-update`, `cargo insta accept`).
- Deleting a failing test, or adding a skip (`@pytest.mark.skip`, `#[ignore]`, `t.Skip`, `xfail`). A parked case goes on the list, not in the file.
- Reporting that tests pass without running them.
- Running only the changed file instead of the suite.
- Not running the new test on its own at least once. Suite-only green hides tests that depend on each other.
- Implementing more than the current test demands. The tell is a branch in the diff that no test exercises.
- Putting nondeterminism in a test (`datetime.now()`, `random`, real network). Every later failure becomes unreadable.
- An assertion that only checks a call count.

## Sources

- Kent Beck, "Canon TDD" <https://newsletter.kentbeck.com/p/canon-tdd> (the loop, the interpretation errors)
- Kent Beck, *Test-Driven Development By Example* (fake it, triangulation, obvious implementation, working clean code)
- Kent Beck, BPlusTree3 `rust/docs/CLAUDE.md` (defect order, running all tests each time)
- 和田卓人「コードを書きながら学ぶ テスト駆動開発」JaSST'18 Tokyo (the three step-size ladders)
- 和田卓人 interview, Agile Journey 2023-11-30 (the test list is the hardest part and the first one is wrong)
