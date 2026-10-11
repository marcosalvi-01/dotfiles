---
description: Implement a previously defined plan
agent: build
---

Implement defined plan step by step. Keep code consistent with repo patterns, `AGENTS.md`, and loaded skills.

# Before each step

Check, in order:

1. Does plan fully specify this step (behavior, shape, edge cases)?
2. If not: does root/module `AGENTS.md` or a loaded skill already resolve it (existing convention, pattern, error-handling rule)?
3. If neither resolves it: STOP. Ask now, before writing any code for this step. Do not batch multiple gaps into one question, do not continue past the gap first.

# Stop and ask when

- Plan references file, function, endpoint, schema, or table that doesn't exist or doesn't match plan's description.
- Plan doesn't specify behavior for edge case that changes output or behavior: error path, nil/empty input, concurrent access, partial failure.
- 2+ valid implementations diverge in observable behavior, API shape, or data schema, and repo pattern doesn't already pick one.
- Step requires touching file/module plan didn't mention.

# Do NOT ask about — resolve silently

- Naming, formatting, import order.
- Anything already mandated by `AGENTS.md` or a loaded skill (e.g. go skill's error-wrapping, sqlc-go's annotation table). That's decided, not ambiguous.
- Straightforward extension of a repo pattern plan clearly implies, even if not spelled out line-by-line.

# Contradiction, not gap

If a step contradicts existing architecture, `AGENTS.md`, or a loaded skill — not just missing a detail — stop entire run, do not patch via question. Flag the contradiction and wait.
