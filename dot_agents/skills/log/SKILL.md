---
name: log
description: Summarize the current session log and append a structured entry to a branch-scoped Markdown note in an Obsidian vault. Use when the user asks to log a session, uses `/log`, asks to save progress/findings, or wants an update generated from `session_log.md`.
---

# Log

Append a timestamped session entry to one Obsidian Markdown log file (branch-scoped by default).

## Workflow

1. Confirm explicit intent to log.
- Trigger on direct requests such as `/log`, "log this session", or "save progress to Obsidian".
- Do not auto-run this skill without explicit user intent.

2. Resolve input.
- Use `SOURCE_DIR` (default: current working directory).
- Read one source file:
  - `session_log.md` by default
  - Override with `LOG_FILE_NAME` or `--log-file`

3. Resolve output target.
- Use `VAULT_ROOT` (default: `/home/aric/Documents/sourdough`).
- Write to one persistent note file.
- Default output path:
  - `session_logs/<repo>/<branch>.md` when `SOURCE_DIR` is inside a git repo
  - `session_log.md` when no git repo is detected
- Override with `OUTPUT_LOG_FILE` or `--output-log-file`.
- Append a new timestamped entry per run.

4. Save the note.
- Prefer the bundled script for deterministic output:
  - `scripts/write_obsidian_note.sh`
- Example:
```bash
/home/aric/.config/opencode/skills/log/scripts/write_obsidian_note.sh \
  --source-dir "$PWD" \
  --vault-root "/home/aric/Documents/sourdough" \
  --log-file "session_log.md" \
  --output-log-file "session_logs/my-repo/feature-branch.md"
```

5. Confirm result.
- Report the updated file path.
- If the source file is missing, note which sections were unavailable.

## Output Structure

Create sections in this order:
1. `Context`
2. `Executive Summary`
3. `Findings`
4. `Progress Completed`
5. `Open Blockers/Risks`
6. `Next Steps`
7. `Tags`

See `references/note-schema.md` for the canonical template.

## Error Handling

- Fail with a clear error if `VAULT_ROOT` does not exist.
- Continue when the source file is missing; record placeholders per section.
- Keep output ASCII and concise.

## Resources

- `scripts/write_obsidian_note.sh`: Generate and write structured session notes.
- `references/note-schema.md`: Note format, tags, and section definitions.
