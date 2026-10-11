---
description: Terse, actionable code review comments — budget-conscious
agent: plan
---

Input: $ARGUMENTS

## Determining What to Review

Pick review type from input:

1. **No arguments (default)**: Review uncommitted changes
   - Run: `git diff` for unstaged changes
   - Run: `git diff --cached` for staged changes
   - Run: `git status --short` to identify untracked (net new) files

2. **Commit hash** (40-char SHA or short hash): Review commit
   - Run: `git show $ARGUMENTS`

3. **Branch name**: Compare current branch with specified branch
   - Run: `git diff $ARGUMENTS...HEAD`

4. **PR URL or number**: Review pull request
   - Run: `gh pr view $ARGUMENTS` for PR context
   - Run: `gh pr diff $ARGUMENTS` for diff

Use best judgement.

Review diffs for unnecessary complexity. One line per finding: location, cut, replacement. Best diff gets shorter.

## Format

`L<line>: <tag> <what>. <replacement>.`, or `<file>:L<line>: ...` for multi-file diffs.

Tags:

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing standard library ships. Name the function.
- `native:` dependency or code duplicating platform feature. Name the feature.
- `yagni:` one-implementation abstraction, unused config, one-caller layer.
- `shrink:` same logic, fewer lines. Show shorter form.

## Examples

❌ "This EmailValidator class might be more complex than necessary, have you considered whether all these validation rules are needed at this stage?"

✅ `L12-38: stdlib: 27-line validator class. "@" in email, 1 line, real validation is the confirmation mail.`

✅ `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

✅ `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`

✅ `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`

✅ `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

If there is nothing to cut, say `Lean already. Ship.` and stop.

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes, performance out of scope. Single smoke test or `assert`-based self-check is ponytail minimum; never flag it. List findings; apply nothing.
