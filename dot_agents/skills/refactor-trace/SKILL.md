---
name: refactor-trace
description: This skill should be used when the user asks to visually explain what changed on a branch, PR, or series of commits from an architectural standpoint — e.g. "show me what changed architecturally", "trace these changes onto the layers", "I don't understand what this refactor did", or "make a refactor trace page". Generates a self-contained HTML page that traces commits onto architecture layers, walks one concrete request through the stack, maps every commit to the rule it moved, and inventories what got deleted.
---

# Refactor Trace

Generate a standalone HTML page that explains a refactor branch by tracing its
changes onto the codebase's architecture layers. The output is a six-section
"trace-down" document: the big idea, the layer stack, a single request walkthrough,
a commit map, a deletion inventory, and the governing principles.

Best suited for consolidation/architecture refactors (DDD migrations, layer
extractions, "move logic out of the UI" branches) where the story is *rules moving
between layers*. For generic diagrams or data tables, prefer a general
visual-explainer approach instead.

## Workflow

### 1. Gather facts

Never write content from memory. Collect:

- `git log --oneline <base>..HEAD` — the commit range (base is usually `main`)
- `git show --stat <sha>` per commit; full `git show <sha>` where needed
- The repo's own architecture vocabulary: AGENTS.md, CLAUDE.md,
  `.garden/context/*.md`, ADRs, docs. Use the project's layer names.
- Grep-verify every claim: deleted symbols are really gone, "lives here now"
  files really contain the rule.

### 2. Distill "the one move"

Refactor branches almost always repeat a single transformation across commits.
Find it and state it in one plain-language sentence — this becomes the hero line
and the lens for every section. If the commits genuinely share no pattern, this
skill is the wrong tool; fall back to a commit-by-commit review page.

### 3. Fill the template

Copy `assets/template.html` and replace the `{{TOKENS}}`, duplicating the blocks
marked `REPEAT` as needed. Follow `references/section-guide.md` for what belongs
in each of the six sections, per-section content rules, and tone.

Layout mechanics to preserve:

- Keep `--i` stagger indices sequential so the fade-in cascade reads top-down.
- Keep the `layer--domain` slot (elevated card) on the layer that owns business
  rules; repurpose slot labels, never CSS class names.
- No emoji. No page-level `.node` class. All grid/flex children keep `min-width: 0`.

### 4. Verify before delivering

- Re-run `git log --oneline` and diff the commit map rows against it — every SHA
  and subject must match.
- `git rev-parse --short HEAD` for the footer.
- Open the file and check both OS themes render (the palette is light-first with a
  `prefers-color-scheme: dark` variant).

### 5. Deliver

- Write to `~/.agent/diagrams/<project>-<topic>-trace.html`.
- Open it: `xdg-open` (Linux) / `open` (macOS).
- Tell the user the file path and give a one-line tour of the six sections.

## Bundled resources

- `assets/template.html` — complete page skeleton: blueprint theme (light + dark),
  sticky TOC with scroll-spy, layer stack cards, trace list, commit table, deletion
  grid, callouts. All CSS/JS finished; only `{{TOKENS}}` and `REPEAT` blocks need
  content.
- `references/section-guide.md` — per-section recipe: what each section must say,
  the git commands to source it, and tone rules. Read it before filling the
  template.
