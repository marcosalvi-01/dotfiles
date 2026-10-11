/** @jsxImportSource @opentui/solid */
import { createSignal } from "solid-js"
import { Plugin } from "@opencode/plugin/tui"
import { CODEX_USAGE_RPC, type Usage, type UsageWindow } from "./rpc.js"

const POLL_INTERVAL_MS = 5 * 60 * 1_000
const RESET_ICON = "󰥔"

const windowLabel = (window: UsageWindow | null | undefined, fallback: string) => {
	const seconds = window?.windowSeconds
	if (seconds === undefined || seconds === null || seconds <= 0) return fallback
	if (seconds >= 6 * 24 * 60 * 60) return `${Math.round(seconds / (24 * 60 * 60))}d`
	if (seconds >= 60 * 60) return `${Math.round(seconds / (60 * 60))}h`
	return `${Math.round(seconds / 60)}m`
}

const usageBar = (used: number, width = 8) => {
	return Math.round((used / 100) * width)
}

const resetLabel = (resetAt: number | undefined, includeDay: boolean) => {
	if (resetAt === undefined) return `${RESET_ICON} -`
	const date = new Date(resetAt)
	if (!Number.isFinite(date.getTime())) return `${RESET_ICON} -`
	const options: Intl.DateTimeFormatOptions = {
		hour: "2-digit",
		minute: "2-digit",
		hourCycle: "h23",
	}
	if (includeDay) {
		options.month = "short"
		options.day = "numeric"
	}
	return `${RESET_ICON} ${new Intl.DateTimeFormat(undefined, options).format(date)}`
}

export default Plugin.define({
	id: "codex-usage-inline",
	setup(context) {
		const [usage, setUsage] = createSignal<Usage | undefined>()
		const controller = new AbortController()
		let refreshing = false
		const usageLabel = (window: Usage["primary"], fallback: string, includeDay: boolean) => {
			if (!window || window.used === null) return
			const filled = usageBar(window.used)
			const resetAt =
				window.resetAfterSeconds === null
					? undefined
					: Date.now() + Math.max(0, window.resetAfterSeconds) * 1_000
			return (
				<>
					{windowLabel(window, fallback)}{" "}
					<span style={{ fg: context.theme.text.muted }}>{"█".repeat(filled)}</span>
					<span style={{ fg: context.theme.border.base }}>{"█".repeat(8 - filled)}</span>
					{` ${window.used}% ${resetLabel(resetAt, includeDay)}`}
				</>
			)
		}

		const refresh = async () => {
			if (refreshing || controller.signal.aborted) return
			refreshing = true
			try {
				setUsage((await context.client.rpc(CODEX_USAGE_RPC).usage({})) as Usage)
			} catch (error) {
				if (!controller.signal.aborted) {
					console.error("[codex-usage] refresh failed:", error)
					setUsage(undefined)
				}
			} finally {
				refreshing = false
			}
		}

		const unregister = context.ui.slot({
			append: "prompt.footer.status",
			render() {
				const value = usage()
				const primary = usageLabel(value?.primary, "5h", false)
				const secondary = usageLabel(value?.secondary, "7d", true)
				const labels = [primary, secondary].filter(Boolean)

				return (
					<text fg={context.theme.text.muted}>
						{labels.length
							? labels.map((label, index) => (
								<>{index > 0 && " | "}{label}</>
							))
							: "usage unavailable"}
						{"  |"}
					</text>
				)
			},
		})

		void refresh()
		const interval = setInterval(() => void refresh(), POLL_INTERVAL_MS)
		return () => {
			controller.abort()
			clearInterval(interval)
			unregister()
		}
	},
})
