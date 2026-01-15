---
name: read-issue
description: Fetch and summarize a GitHub issue. Use when the user mentions an issue number (#123), pastes a GitHub issue URL, or asks to read/see/show an issue.
---

# Read GitHub Issue

Fetch and present a GitHub issue clearly.

## Recognizing Issue References

- Issue number: `#123`, `issue 123`, `issue #123`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- Contextual: "look at the issue", "check that issue", "what does the issue say"

## Workflow

1. **Determine the issue reference:**
   - If a URL is provided, extract owner/repo/number
   - If just a number, use the current repository

2. **Fetch the issue using GitHub CLI:**
   ```bash
   gh issue view <number> --json title,body,state,labels,assignees,comments,author,createdAt,url
   ```

3. **Present the issue clearly:**
   - Title and state (open/closed)
   - Author and creation date
   - Labels (if any)
   - Body content (the main description)
   - Key comments (if relevant)

## Output Format

Present the issue in a scannable format:

```
## Issue #123: <title>
**State:** Open | **Author:** @username | **Created:** 2024-01-15
**Labels:** bug, priority-high

### Description
<issue body content>

### Key Comments (if any)
- @commenter: <summary of comment>
```

## Notes

- Keep summaries concise but complete
- Highlight actionable items or acceptance criteria if present
- Note any linked PRs or related issues mentioned
