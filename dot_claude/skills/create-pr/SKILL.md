---
name: submit-pr
description: Create a pull request using GitHub CLI. Follows a structured template with issue reference, change description, and testing checklist.
---

# Submit Pull Request

Create a pull request using the GitHub CLI (`gh`).

## Title Requirements

- DO NOT include commit prefixes (e.g., feat:, chore:, fix:, docs:, etc.)
- Capitalize the first letter of the title
- Write a clear, descriptive title that explains what the PR does

Examples:
- ✅ Good: "Remove debug console.log statements"
- ❌ Bad: "chore: remove debug console.log statements"

## Description Template

The PR description must include these three sections:

### What issue does this close?

Reference the issue number that this PR closes. The issue number should typically be found in the branch name.

Example: `Closes #1368`

### Describe what changes were introduced in this pull request

Provide a concise overview of the changes. Focus on the key changes and their purpose.

### Local testing

Include a checklist of testing steps performed or to be performed.

Example:
- [ ] Test item 1
- [ ] Test item 2
- [ ] Test item 3

## Workflow

1. **Push the branch to remote:**
   ```bash
   git push -u origin <branch-name>
   ```

2. **Create the PR using `gh pr create`:**
   ```bash
   gh pr create --title "Your PR title" --body "$(cat <<'EOF'
   ## What issue does this close?

   Closes #1234

   ## Describe what changes were introduced in this pull request

   Your description here...

   ## Local testing

   - [ ] Test item 1
   - [ ] Test item 2
   EOF
   )"
   ```

The command will output the URL of the created pull request.
