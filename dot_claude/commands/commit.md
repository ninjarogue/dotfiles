---
argument-hint: [message]
description: Create a git commit
---

Arguments: $ARGUMENTS

Parse the arguments:
- If `--staged` is present anywhere in the arguments → **Staged mode**: create a single commit. Remove `--staged` from the text and use the rest as the commit message.
- Otherwise → **Default mode**: create atomic commits, using the text as optional context/message.

# Git Commit Guidelines

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

---

## Staged Mode (`--staged`)

Create a single commit with the provided message:

1. **Review staged changes:**
   ```bash
   git status
   git diff --staged
   ```

2. **Create a single commit** using the provided message (add appropriate prefix if not already included):
   ```bash
   git commit -m "prefix: message"
   ```

---

## Default Mode (Atomic Commits)

Organize all changes into atomic commits:

### Creating Atomic Commits

1. **Review all changes:**

   ```bash
   git status
   git diff
   git log --oneline -5  # Check recent commit style
   ```

2. **Plan atomic commits:**
   - Each commit should represent ONE logical change
   - Group related changes together
   - Separate unrelated changes into different commits
   - Consider the order - dependencies should be committed first

3. **Stage and commit each change separately:**
   ```bash
   git add <specific-files>
   git commit -m "prefix: descriptive message"
   ```

### Example Workflow

Given multiple changes across different files:

1. **First, analyze the changes:**

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
   # Commit 1
   git add src/components/MyComponent.tsx
   git commit -m "ref: reorganize component props for readability"

   # Commit 2
   git add src/components/Container.tsx src/hooks/useVisibility.ts
   git commit -m "feat: add visibility control to preserve state"

   # Commit 3
   git add src/utils/validation.ts
   git commit -m "fix: handle edge case in validation"
   ```

---

## Best Practices (Both Modes)

- **Clear messages:** Explain what changed and why (if not obvious)
- **Present tense:** Use "add" not "added", "fix" not "fixed"
- **Concise:** Keep the first line under 72 characters

## Commit Body Guidelines

**IMPORTANT:** Only include a commit body when the title alone is insufficient to understand the change.

- **Prefer title-only commits:** Most commits should have only a descriptive title
- **Minimal body when needed:** If a body is required, keep it as concise as possible (1-2 lines max)
- **When to add a body:**
  - Complex changes requiring brief context
  - Non-obvious "why" behind the change
  - Important caveats or side effects

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

- Always run linting/type-checking before committing if available (check project's README or package.json for commands)
- Review each commit with `git show` to ensure it contains exactly what you intended
- Use `git commit --amend` to fix the last commit if needed (before pushing)
