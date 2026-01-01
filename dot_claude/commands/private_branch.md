---
argument-hint: [description]
description: Create a git branch with conventional prefix
---

Arguments: $ARGUMENTS

# Git Branch Creation

Create a new branch based on current changes or the provided description.

## Branch Prefix Convention

Use the same prefixes as commits, but with `/` instead of `:`:

- `feat/` - New feature or functionality
- `fix/` - Bug fix
- `ref/` - Refactoring code (improving structure without changing behavior)
- `chore/` - Maintenance tasks (updating dependencies, config, etc.)
- `docs/` - Documentation changes
- `test/` - Adding or updating tests
- `style/` - Code style changes (formatting, whitespace, etc.)
- `perf/` - Performance improvements

## Workflow

1. **Analyze context:**
   - If arguments provided, use them to determine branch type and name
   - If no arguments, check `git diff` and `git status` to understand current changes

2. **Determine branch type:**
   - Analyze the nature of the changes/description
   - Select the appropriate prefix

3. **Create branch name:**
   - Use kebab-case for the branch name
   - Keep it concise but descriptive (2-4 words typically)
   - Format: `prefix/short-descriptive-name`

4. **Create the branch:**
   ```bash
   git checkout -b prefix/branch-name
   ```

## Examples

- Adding a new login feature → `feat/user-login`
- Fixing a bug in validation → `fix/validation-edge-case`
- Refactoring dashboard layout → `ref/dashboard-layout`
- Updating dependencies → `chore/update-deps`
- Adding unit tests → `test/auth-unit-tests`

## Notes

- Do NOT include issue numbers unless explicitly provided
- Choose the branch name yourself - be concise and descriptive
- If changes span multiple types, choose the primary purpose
