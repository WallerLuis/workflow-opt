/**
 * git-guard — pi project extension for workflow-opt.
 *
 * Blocks `git commit`, `git push` and `git reset --hard` issued through pi's bash tool.
 * AGENTS.md → Approval contract 2: the agent writes the commit message, Luis runs the command.
 *
 * Mechanism: a `tool_call` handler returning `{ block: true, reason }` stops the call before it
 * executes (pi docs/extensions.md). Deterministic, zero tokens. Always blocks — no confirm dialog,
 * because the contract is "never", not "ask".
 *
 * Loads from `.pi/extensions/` only after project trust is granted (`/trust`, pi docs/security.md).
 * Claude Code has the equivalent in `.claude/settings.json` → `permissions.deny`.
 *
 * Limits, stated: this is a pattern match on the command string, not containment. It catches
 * prefixes (`cd x &&`, `;`, `|`, env assignments, `sh -c "…"`, `/usr/bin/git`) and global git
 * options (`-C dir`, `-c k=v`, `--no-pager`, `--git-dir=…`). It does not catch git aliases, a
 * script file that runs git, or another tool than bash.
 *
 * Fail-closed by design: a quote counts as a command boundary so `sh -c "git push"` is caught, which
 * means `grep -r 'git push' docs` is blocked too. Accepted — pi's own grep/read tools cover searching.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// `git` as a command word: start of string or after a shell separator/quote, optional path prefix.
const GIT = String.raw`(?:^|[\s;&|()\x60'"])(?:[^\s;&|()\x60'"]*/)?git`;
// Global options that may sit between `git` and the subcommand.
const OPTS = String.raw`(?:\s+(?:-C\s+\S+|-c\s+\S+|--(?:git-dir|work-tree|namespace)(?:=\S+|\s+\S+)|--[\w-]+|-[A-Za-z]+))*`;

const RULES: Array<{ name: string; re: RegExp }> = [
	{ name: "git commit", re: new RegExp(`${GIT}${OPTS}\\s+commit(?![\\w-])`) },
	{ name: "git push", re: new RegExp(`${GIT}${OPTS}\\s+push(?![\\w-])`) },
	{ name: "git reset --hard", re: new RegExp(`${GIT}${OPTS}\\s+reset(?![\\w-])[^;&|\\n]*\\s--hard(?![\\w-])`) },
];

/** Returns the blocked operation's name, or undefined when the command is allowed. */
export function blockedOperation(command: string): string | undefined {
	return RULES.find((r) => r.re.test(command))?.name;
}

export default function gitGuard(pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;
		const input: unknown = event.input;
		const command =
			input && typeof input === "object" && "command" in input && typeof input.command === "string"
				? input.command
				: "";
		const op = blockedOperation(command);
		if (!op) return undefined;

		const reason =
			`${op} is blocked in workflow-opt (AGENTS.md → Approval contract 2). ` +
			"Write the commit message and a diff summary instead; Luis runs the command.";
		if (ctx.hasUI) ctx.ui.notify(`git-guard: blocked ${op}`, "warning");
		return { block: true, reason };
	});
}
