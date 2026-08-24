# Section-by-Section Content Guide

How to fill each of the six sections in `assets/template.html`. The section order is a
deliberate reading path: concept → structure → one concrete request → history →
deletions → principles. Do not reorder or skip sections without reason; the single
request trace (section 3) is the linchpin that makes abstract layer talk click.

## Gathering facts first

Run these before writing any content. Never write a SHA, file path, or symbol name
from memory.

```bash
git log --oneline <base>..HEAD          # commit list; base is usually main
git show --stat <sha>                   # files touched per commit
git show <sha>                          # full diff when the stat isn't enough
git diff --stat <base>...HEAD           # branch-wide footprint
```

Also read any architecture documentation the repo has (AGENTS.md, CLAUDE.md,
`.garden/context/*.md`, ADRs, docs/architecture) to get the project's own names for
its layers. Use the project's vocabulary, not generic textbook terms.

Verify claims in code: for every "X was deleted" grep that X is really gone; for
every "rule lives in Y now" open Y and confirm.

## Section 1 — The Big Idea

The hero card. One sentence stating the single move all the commits repeat.
Refactor branches almost always repeat one transformation; find it by asking
"what did every commit do that the others also did?"

- `{{BIG_IDEA_SENTENCE}}`: present tense, plain words, `<em>` on the 2-3 pivotal
  phrases. Example shape: "Every commit is the same move, repeated: find a business
  rule the UI was re-deriving, move it to the domain, ship the server's answer as a
  flag on the response, and delete the UI's copy."
- Before/after panels: 3 bullets each, mirrored (bullet N before corresponds to
  bullet N after). Concrete symbols in `<code>`.
- Bug chips: only real bugs with observable symptoms. If the refactor fixed no
  bugs, delete the chip row and the summary line rather than inventing weak ones.
- `{{BUGS_SUMMARY_LINE}}`: one sentence tying the bugs to the structural cause,
  e.g. "All four existed because a rule was written twice."

## Section 2 — The Layer Stack

One card per layer, outermost first, connected by labeled arrows. Five color slots
exist (`layer--ui`, `layer--server`, `layer--app`, `layer--domain`, `layer--infra`);
use as many as the architecture has layers, and give the elevated `layer--domain`
slot to whichever layer owns the business rules. For non-DDD codebases repurpose the
slots (e.g. component / route / store / API client / backend) — change only the
visible labels, never the class names.

Per card:

- **Job**: the layer's responsibility in one sentence, stated as a rule
  ("transport only", "pure invariants, no I/O").
- **Was doing / Now does** minis: the contrast that carries the whole page. "Was"
  names the smell concretely; "Now" names the replacement mechanism.
- **File row**: 2-4 real filenames, middot-separated. Not exhaustive — representative.
- Arrows between cards: label with the handoff verb ("calls server function",
  "passes Actor down", "implements ports defined by").

Close with a callout naming the enforcement mechanism, if any (e.g. "the DTO fields
are required, so forgetting them is a compile error").

## Section 3 — Trace: a single request

Pick ONE user-visible scenario that crosses every layer (opening a detail page,
submitting a form). Number the steps; each step gets a layer badge (`who--*`) and
names the real function or file in `<code>`. 5-8 steps. The last step should land
back where the first started, showing the round trip.

Choose the scenario that best showcases what changed — if the refactor moved
permission logic, trace a request where permissions matter.

## Section 4 — Commit Map

One table row per commit, oldest first. SHAs from `git log`, 7 chars. Columns:

- **Commit**: `sha` span + subject in `small`.
- **Rule that moved**: the business rule in domain language, not code language.
- **Where it lives now**: file/symbol in `<code>`.
- **What it fixed / removed**: lead with a `fix-chip` (2-5 words), then one
  sentence of detail. Chore/cleanup commits get an em-dash in unused columns
  rather than padded prose.

Include every commit in the range, even trivial ones — the map's completeness is
what makes it trustworthy. Verify the SHA list against `git log` immediately before
delivering.

## Section 5 — What Got Deleted

One card per deleted file, function, or config flag, with strikethrough name and a
two-line story: why it existed, what replaced it. In consolidation refactors the
deletions ARE the deliverable, so this section gets equal billing with the commits.
Grep to confirm each deletion actually happened before listing it.

## Section 6 — The Rules of the Game

Two principle cards + callouts:

- Each principle card: short title, a monospace arrow diagram (one line, e.g.
  "domain ← application ← infrastructure ← UI"), and a 2-3 sentence explanation of
  what the arrow direction forbids and permits.
- **The one-file test** callout: "if rule X changes tomorrow, which single file do
  you edit?" — answer it for the 2-3 main rules the branch touched. This is the
  acceptance test for the whole refactor.
- **Still open** callout (optional, amber border): honest list of items discovered
  but not fixed. Delete the callout if there are none; never leave the page
  implying completeness it doesn't have.

Footer line: branch @ HEAD sha, verified against `git rev-parse --short HEAD`.

## Tone rules

- Plain words over jargon; the reader is a teammate catching up, not the author.
- Every claim traceable to a diff, a file, or a command output.
- No emoji anywhere on the page.
- Keep prose in cells and minis to 1-2 sentences; the layout does the organizing.
