import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const COMMAND_TIMEOUT_MS = 60_000;

function redactSecrets(text: string): string {
	return text.replace(/\b(fc|sk-tinyfish|sk-mino)-[A-Za-z0-9_-]+\b/g, "$1-[redacted]");
}

function compactError(error: unknown): string {
	const message = error instanceof Error ? error.message : String(error);
	return redactSecrets(message).replace(/\s+/g, " ").trim().slice(0, 500);
}

async function runDeveloperSearch(
	pi: ExtensionAPI,
	query: string,
	limit: number,
	signal?: AbortSignal,
): Promise<any> {
	if (signal?.aborted) throw new Error("Operation cancelled");

	let result;
	try {
		result = await pi.exec(
			"firecrawl",
			["developer", query, "--limit", String(limit), "--json"],
			{ signal, timeout: COMMAND_TIMEOUT_MS },
		);
	} catch (error) {
		if (signal?.aborted) throw new Error("Operation cancelled");
		throw new Error(`firecrawl failed: ${compactError(error)}`);
	}

	if (signal?.aborted) throw new Error("Operation cancelled");
	if (result.code !== 0) {
		const reason = result.stderr.trim() || result.stdout.trim() || `exit code ${result.code}`;
		throw new Error(`firecrawl failed: ${compactError(reason)}`);
	}

	try {
		return JSON.parse(result.stdout.trim());
	} catch {
		throw new Error("firecrawl returned invalid JSON");
	}
}

async function truncateOutput(text: string) {
	const redacted = redactSecrets(text);
	const truncation = truncateHead(redacted, {
		maxLines: DEFAULT_MAX_LINES,
		maxBytes: DEFAULT_MAX_BYTES,
	});
	if (!truncation.truncated) return { text: truncation.content };

	const directory = await mkdtemp(join(tmpdir(), "pi-developer-search-"));
	const fullOutputPath = join(directory, "output.md");
	await writeFile(fullOutputPath, redacted, { encoding: "utf8", mode: 0o600 });
	return {
		text: `${truncation.content}\n\n[Output truncated: ${truncation.outputLines}/${truncation.totalLines} lines (${formatSize(truncation.outputBytes)}/${formatSize(truncation.totalBytes)}). Full output: ${fullOutputPath}]`,
		fullOutputPath,
	};
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "firecrawl_developer_search",
		label: "Developer Search",
		description:
			"Search Firecrawl's Developer Index of documentation, READMEs, issues, and merged pull requests. Returns primary-source passages and URLs. Output is truncated to Pi's standard limits when necessary.",
		promptSnippet: "Search primary developer documentation, READMEs, issues, and merged pull requests",
		promptGuidelines: [
			"Use firecrawl_developer_search first for library or API behavior, documentation, error messages, known bugs, and fixes; quote relevant passages and cite their URLs.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Natural-language developer question or exact error text" }),
			limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 100, description: "Maximum results (default 10)" })),
		}),
		async execute(_toolCallId, params, signal) {
			const data = await runDeveloperSearch(pi, params.query, params.limit ?? 10, signal);
			if (!Array.isArray(data?.results) || data.results.length === 0) {
				return {
					content: [{ type: "text", text: "Firecrawl Developer Index returned no results." }],
					details: { resultCount: 0 },
				};
			}

			const lines = ["Provider: firecrawl-developer"];
			for (const [index, result] of data.results.entries()) {
				const url = typeof result.url === "string" ? result.url : "URL unavailable";
				const title = typeof result.title === "string" && result.title ? result.title : url;
				lines.push("", `## ${index + 1}. ${title}`, `ID: ${String(result.id ?? "unknown")}`, url);
				if (Array.isArray(result.passages)) {
					for (const passage of result.passages) {
						if (typeof passage?.text === "string") lines.push("", passage.text);
					}
				}
			}

			const output = await truncateOutput(lines.join("\n"));
			return {
				content: [{ type: "text", text: output.text }],
				details: {
					provider: "firecrawl-developer",
					resultCount: data.results.length,
					fullOutputPath: output.fullOutputPath,
				},
			};
		},
	});
}
