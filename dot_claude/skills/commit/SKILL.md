---
name: commit
description: Create git commits using conventional commit format. Organizes changes into atomic commits where each commit represents one logical change.
---

# Git Commit

Create atomic commits that each represent one logical change.

## Commit Message Format

Use conventional commit format with these prefixes:

- `feat:` - New feature or functionality
- `fix:` - Bug fix
- `ref:` - Refactoring code (improving structure without changing behavior)
- `chore:` - Maintenance tasks (updating dependencies, config, etc.)
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `style:` - Code style changes (formatting, whitespace, etc.)
- `perf:` - Performance improvements

## Workflow

### 1. Review all changes

```bash
git status
git diff
git log --oneline -5  # Check recent commit style
```

### 2. Plan atomic commits

- Each commit should represent ONE logical change
- Group related changes together
- Separate unrelated changes into different commits
- Consider the order - dependencies should be committed first

### 3. Stage and commit each change separately

```bash
git add <specific-files>
git commit -m "prefix: descriptive message"
```

## Example Workflow

Given multiple changes across different files:

1. **Analyze the changes:**
   ```bash
   git status
   git diff
   ```

2. **Create a plan:**
   - Commit 1: ref: reorganize component props for readability
   - Commit 2: feat: add visibility control to preserve state
   - Commit 3: fix: handle edge case in validation

3. **Execute the plan:**
   ```bash
   git add src/components/MyComponent.tsx
   git commit -m "ref: reorganize component props for readability"

   git add src/components/Container.tsx src/hooks/useVisibility.ts
   git commit -m "feat: add visibility control to preserve state"

   git add src/utils/validation.ts
   git commit -m "fix: handle edge case in validation"
   ```

## Best Practices

- **Clear messages:** Explain what changed and why (if not obvious)
- **Present tense:** Use "add" not "added", "fix" not "fixed"
- **Concise:** Keep the first line under 72 characters

## Commit Body Guidelines

Only include a commit body when the title alone is insufficient.

- **Prefer title-only commits:** Most commits should have only a descriptive title
- **Minimal body when needed:** If required, keep it to 1-2 lines max
- **When to add a body:** Complex changes, non-obvious reasoning, important caveats

### Examples

Title-only commit (preferred):
```bash
git commit -m "feat: add JWT authentication with refresh tokens"
```

With minimal body (only when necessary):
```bash
git commit -m "$(cat <<'EOF'
fix: resolve race condition in token refresh

Adds mutex to prevent concurrent refresh attempts
EOF
)"
```

## Remember

- Always run linting/type-checking before committing if available
- Review each commit with `git show` to ensure correctness
- Use `git commit --amend` to fix the last commit if needed (before pushing)
