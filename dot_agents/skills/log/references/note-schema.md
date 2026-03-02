# Obsidian Session Note Schema

Use this structure for each appended session entry.

## Section Order

1. `Context`
2. `Executive Summary`
3. `Findings`
4. `Progress Completed`
5. `Open Blockers/Risks`
6. `Next Steps`
7. `Tags`

## Requirements

- Append to one persistent log file (branch-scoped by default).
- Add a timestamp heading per entry: `## YYYY-MM-DD HH:MM`.
- Keep bullets concise and actionable.
- Record a missing source file explicitly in `Context`.
- Preserve ASCII output.

## Default Tags

`#codex #session-log #progress`

## Output Log File

`session_logs/<repo>/<branch>.md` when the source directory is in git; otherwise `session_log.md`.

Override with `OUTPUT_LOG_FILE` or `--output-log-file`.
