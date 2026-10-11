import { Plugin } from "@opencode/plugin"
import { CODEX_USAGE_RPC } from "./rpc.js"

const MODELS_URL = "https://chatgpt.com/backend-api/codex/models?client_version=1.0.0"
const RESPONSES_URL = "https://chatgpt.com/backend-api/codex/responses"
const TIMEOUT_MS = 10_000

const numberHeader = (headers: Headers, name: string) => {
	const value = headers.get(name)
	if (value === null || value.trim() === "") return null
	const parsed = Number(value)
	return Number.isFinite(parsed) ? parsed : null
}

const codexHeaders = (access: string, accountId: string) => ({
	Authorization: `Bearer ${access}`,
	accept: "application/json",
	"openai-beta": "responses=experimental",
	originator: "codex_cli_rs",
	"chatgpt-account-id": accountId,
})

const fetchUsage = async (access: string, accountId: string) => {
	const signal = AbortSignal.timeout(TIMEOUT_MS)
	const modelsResponse = await fetch(MODELS_URL, {
		headers: codexHeaders(access, accountId),
		signal,
	})
	if (!modelsResponse.ok) {
		throw new Error(`Codex models request failed: HTTP ${modelsResponse.status}`)
	}

	const models: unknown = await modelsResponse.json()
	const entries =
		typeof models === "object" && models !== null && "models" in models
			? (models as { models?: unknown }).models
			: undefined
	if (!Array.isArray(entries)) {
		throw new Error("Codex models response had unexpected shape")
	}
	const model = (
		entries.find((item) => {
			if (typeof item !== "object" || item === null) return false
			return typeof (item as { slug?: unknown }).slug === "string"
		}) as { slug: string } | undefined
	)?.slug
	if (!model) throw new Error("No Codex model available for quota probe")

	const response = await fetch(RESPONSES_URL, {
		method: "POST",
		headers: {
			...codexHeaders(access, accountId),
			"content-type": "application/json",
			accept: "text/event-stream",
		},
		body: JSON.stringify({
			model,
			instructions: "You are a coding assistant.",
			input: [{ role: "user", content: [{ type: "input_text", text: "reply ok" }] }],
			store: false,
			stream: true,
		}),
		signal,
	})
	if (!response.ok) {
		throw new Error(`Codex quota request failed: HTTP ${response.status}`)
	}
	await response.text()

	const window = (prefix: "primary" | "secondary") => {
		const used = numberHeader(response.headers, `x-codex-${prefix}-used-percent`)
		const resetAfterSeconds = numberHeader(response.headers, `x-codex-${prefix}-reset-after-seconds`)
		const windowMinutes = numberHeader(response.headers, `x-codex-${prefix}-window-minutes`)
		if (used === null) return null
		return {
			used: Math.round(Math.max(0, Math.min(100, used))),
			resetAfterSeconds,
			windowSeconds: windowMinutes === null ? null : windowMinutes * 60,
		}
	}

	return {
		primary: window("primary"),
		secondary: window("secondary"),
	}
}

export default Plugin.define({
	id: "marco.codex-usage",
	async setup(ctx) {
		const registration = await ctx.rpc.register(CODEX_USAGE_RPC, {
			async usage() {
				const connection = await ctx.integration.connection.active("openai")
				if (!connection) throw new Error("No active OpenAI OAuth connection")

				const credential = await ctx.integration.connection.resolve(connection)
				if (credential?.type !== "oauth") throw new Error("Active OpenAI connection is not OAuth")

				const accountID = credential.metadata?.accountID ?? credential.metadata?.accountId
				if (typeof accountID !== "string" || !accountID.trim()) {
					throw new Error("OpenAI OAuth credential has no account ID")
				}

				return fetchUsage(credential.access, accountID)
			},
		})

		return () => registration.dispose()
	},
})
