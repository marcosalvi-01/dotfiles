import { Rpc } from "@opencode/plugin/rpc"

const nullableNumber = { anyOf: [{ type: "number" }, { type: "null" }] } as const
const nullableWindow = {
	anyOf: [
		{
			type: "object",
			properties: {
				used: nullableNumber,
				resetAfterSeconds: nullableNumber,
				windowSeconds: nullableNumber,
			},
			required: ["used", "resetAfterSeconds", "windowSeconds"],
			additionalProperties: false,
		},
		{ type: "null" },
	],
} as const

export type UsageWindow = {
	used: number | null
	resetAfterSeconds: number | null
	windowSeconds: number | null
}

export type Usage = {
	primary: UsageWindow | null
	secondary: UsageWindow | null
}

export const CODEX_USAGE_RPC = Rpc.define({
	id: "marco.codex-usage",
	methods: {
		usage: {
			input: { type: "object", additionalProperties: false },
			output: {
				type: "object",
				properties: { primary: nullableWindow, secondary: nullableWindow },
				required: ["primary", "secondary"],
				additionalProperties: false,
			},
		},
	},
	events: {},
})
