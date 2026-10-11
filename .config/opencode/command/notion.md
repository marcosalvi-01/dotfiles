---
description: Analyze a Notion task against current codebase
agent: plan
---

Given a Notion task reference in `$ARGUMENTS` (URL, title, or both), do the following:

1. Resolve the task with Notion MCP:

- First use notion-find or notion-search to locate the task.
- Then notion-fetch the selected page.
- If multiple plausible matches exist, ask one concise disambiguation question.

2. Extract task intent and classify it as one of:

- already_done_check
- brainstorming
- implementation

3. Contextualize against the current repository:

- Identify likely relevant files/modules/tests.
- Inspect code to determine whether the task is already implemented, partially implemented, obsolete, or still pending.
- Cite concrete evidence with file paths and short rationale.

4. Respond with this structure:
   Task Snapshot

- Title, status, due date/priority (if available)
- One-sentence intent
  Codebase Reality Check
- Findings with evidence (`path:line` when useful)
- Verdict: `already done`, `partially done`, `not done`, or `obsolete`
  Recommendation
- If already done/obsolete: explain why and stop.
- If brainstorming: provide focused ideas, tradeoffs, unknowns, and 2-3 next experiments.
- If implementation: provide a phased plan (steps, touched files, risks, validation/tests).
  Constraints:
- Do not edit files or run destructive actions.
- Be concise, evidence-based, and explicit about uncertainty.
