import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)

const escapeAppleScript = (value) =>
	String(value)
		.replaceAll("\\", "\\\\")
		.replaceAll('"', '\\"')
		.replaceAll(/[\r\n]+/g, " ")

const appleScriptString = (value) => `"${escapeAppleScript(value)}"`

const truncate = (value, length) => {
	const text = String(value).replace(/\s+/g, " ").trim()
	return text.length > length ? `${text.slice(0, length - 3)}...` : text
}

const notify = async ({ title, subtitle, message, sound }) => {
	const script = [
		`display notification ${appleScriptString(message)}`,
		`with title ${appleScriptString(title)}`,
		subtitle && `subtitle ${appleScriptString(subtitle)}`,
		sound && `sound name ${appleScriptString(sound)}`,
	]
		.filter(Boolean)
		.join(" ")

	await execFileAsync("osascript", ["-e", script])
}

export default {
	id: "notifications",
	async setup(ctx) {
		await ctx.tool.hook("execute.before", (event) => {
			if (event.tool.toLowerCase() !== "question") return

			const questions = Array.isArray(event.input?.questions) ? event.input.questions : []
			const firstQuestion = questions[0]?.question
			const count = questions.length

			void notify({
				title: "OpenCode needs your answer",
				subtitle: `${count > 0 ? count : "A"} question${count === 1 ? "" : "s"} pending`,
				message: firstQuestion
					? truncate(firstQuestion, 180)
					: "Open OpenCode to answer the pending question.",
				sound: "Submarine",
			}).catch(() => {})
		})

		const controller = new AbortController()
		void (async () => {
			try {
				for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
					if (event.type === "permission.asked") {
						const permission = String(event.properties?.permission ?? "requested").replaceAll("_", " ")
						const patterns = Array.isArray(event.properties?.patterns) ? event.properties.patterns : []
						const firstPattern = patterns[0]
						const additionalPatterns = patterns.length > 1 ? ` (+${patterns.length - 1} more)` : ""

						void notify({
							title: "OpenCode needs permission",
							subtitle: `${permission} access requested`,
							message: firstPattern
								? `${truncate(firstPattern, 160)}${additionalPatterns}`
								: "Open OpenCode to allow or deny this request.",
							sound: "Basso",
						}).catch(() => {})
						continue
					}

					if (event.type !== "session.idle") continue

					const sessionID = event.properties?.sessionID
					if (!sessionID) continue

					try {
						const session = await ctx.session.get({ sessionID })
						if (session.parentID) continue
					} catch {
						continue
					}

					void notify({
						title: "OpenCode task complete",
						subtitle: "Ready for review",
						message: "Your task finished. Return to OpenCode to review the result.",
						sound: "Glass",
					}).catch(() => {})
				}
			} catch (error) {
				if (!controller.signal.aborted) console.error("OpenCode notification event stream failed", error)
			}
		})()

		return () => controller.abort()
	},
}
