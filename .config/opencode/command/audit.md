---
description: Whole-repo audit for over-engineering
agent: plan
---

ponytail-review, repo-wide. Scan whole tree, not diff. Rank biggest cut first.

## Tags

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing standard library ships. Name the function.
- `native:` dependency or code duplicating platform feature. Name the feature.
- `yagni:` one-implementation abstraction, unused config, one-caller layer.
- `shrink:` same logic, fewer lines. Show shorter form.

## Hunt

Hunt stdlib/platform duplicates, one-implementation interfaces, one-product factories, delegating wrappers, one-export files, dead flags/config, hand-rolled stdlib.

## Output

One ranked line per finding: `<tag> <what to cut>. <replacement>. [path]`.
End with `net: -<N> lines, -<M> deps possible.` Nothing to cut: `Lean already. Ship.`

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes, performance out of scope. List findings; apply nothing. One-shot.
