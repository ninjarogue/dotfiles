---
description: Commit changes
agent: build
model: anthropic/claude-opus-4-5
---

Read the arguments for further instruction (optional): $ARGUMENTS

Create a git commit using "Conventional Commits" format.

Only use the following prefixes: feat, fix, docs, style, ref, perf, test, chore, ci.

Format: `type: description`

- Examine the changes and split it into atomic commits if necessary
- Lowercase, imperative mood
- Start with a concise subject line: Summarize the change in 50 characters or less.
- Add a concise description (optional): Explain the 'what' and 'why', not the 'how'.
- Keep the commit it concise
- Cleanup code: remove commented code, fix TODOs, remove unused imports, fix linting.
