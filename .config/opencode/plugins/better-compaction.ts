export default {
	id: "better-compaction",
	async setup(ctx) {
		await ctx.session.hook("compaction", (event) => {
			event.system = [{
				type: "text",
				text: `You are compacting a conversation so it can continue in a new context window.

CRITICAL — never generalize away:
1. Exact names, paths, values, error messages, flag names, config keys, URLs, version numbers.
2. Any decision, constraint, or preference the user stated ("don't use X", "keep backward compat with Y", naming choices) — quote them, don't paraphrase.
3. If the user pasted external content (logs, errors, config, code), reproduce the key parts verbatim, not summarized.
4. Which hypotheses were tried and ruled out during debugging, and why.
5. Current state of each file touched: what changed, what's still pending.

Format as:
## Decisions & constraints (verbatim)
## Files touched (state)
## What's done
## What's next
## Open questions not yet resolved`,
			}]
		})
	},
}
