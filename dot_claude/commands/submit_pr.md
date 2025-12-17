# Pull Request Description Template

When creating a pull request, follow these guidelines and use the GitHub CLI (`gh`) to create the PR:

## Title Requirements
- DO NOT include commit prefixes (e.g., feat:, chore:, fix:, docs:, etc.)
- Capitalize the first letter of the title
- Write a clear, descriptive title that explains what the PR does

Example:
- ✅ Good: "Remove debug console.log statements"
- ❌ Bad: "chore: remove debug console.log statements"

## Description Requirements
The description must include the following three sections:

## What issue does this close?

Reference the issue number that this PR closes. The issue number should typically be found in the branch name.

Example: `Closes #1368`

## Describe what changes were introduced in this pull request

Provide a concise overview of the changes. Focus on the key changes and their purpose.

## Local testing

Include a checklist of testing steps that were performed or should be performed to validate the changes.

Example:
- [ ] Test item 1
- [ ] Test item 2
- [ ] Test item 3

## Creating the Pull Request

After preparing the PR description above, create the pull request using the GitHub CLI:

1. First, ensure the branch is pushed to remote:
   ```bash
   git push -u origin <branch-name>
   ```

2. Create the PR using `gh pr create`:
   ```bash
   gh pr create --title "<PR title>" --body "<PR description>"
   ```

   Or use a heredoc for the body:
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