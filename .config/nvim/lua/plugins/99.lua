return {
	"ThePrimeagen/99",
	config = function()
		local _99 = require("99")
		local opts = {
			completion = {
				custom_rules = {
					"~/.config/opencode/skills/"
				},
				source = "blink"
			},
			provider = _99.OpenCodeProvider,
			model = "openai/gpt-5.3-codex",
			-- model = "openai/gpt-5.1-codex-mini",
			tmp_dir = "~/tmp/99",
		}

		_99.setup(opts)
	end,
	keys = {
		{
			"<leader>ia",
			function()
				require("99").visual()
			end,
			mode = "v",
			desc = "99 visual",
		},
		{
			"<leader>id",
			function()
				require("99").visual({
					additional_prompt = [[
Add debugging statements to this function.
Follow debugprint.nvim style:
- Use the DEBUGPRINT tag.
- Match language-specific debugprint formatting conventions.
- Add logs at entry, key branches, and before return points.
- Do not change function signature, behavior, code, or control flow. Keep it as is.
- Keep changes focused to debug statements only.
]],
				})
			end,
			mode = "v",
			desc = "99 add debug statements",
		},
		{
			"<leader>if",
			function()
				require("99").visual({
					additional_prompt = [[
Fill in this function implementation.
Do not change the function signature in any way.
The implementation must strictly follow the existing signature
(name, arguments, generics, return type, visibility/modifiers, async-ness).
Only implement or replace the function body.
]],
				})
			end,
			mode = "v",
			desc = "99 fill function body",
		},
		{
			"<leader>is",
			function()
				require("99").stop_all_requests()
			end,
			desc = "99 stop",
		},
	},
}
