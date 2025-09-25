# Git Commit Guidelines

When creating commits, follow these guidelines to ensure clean, atomic commits that clearly communicate changes.

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

## Creating Atomic Commits

Before committing, organize your changes into a plan:

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

## Best Practices

- **Atomic commits:** Each commit should be self-contained and represent a single logical change
- **Clear messages:** Explain what changed and why (if not obvious)
- **Present tense:** Use "add" not "added", "fix" not "fixed"
- **Concise:** Keep the first line under 72 characters
- **Test before committing:** Ensure the code works at each commit point

## Example Workflow

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

## Using Heredocs for Longer Messages

For commits requiring more context:
```bash
git commit -m "$(cat <<'EOF'
feat: implement user authentication system

Added JWT-based authentication with refresh tokens.
Includes login, logout, and token refresh endpoints.
EOF
)"
```

## Remember

- Always run linting/type-checking before committing if available (check project's README or package.json for commands)
- Review each commit with `git show` to ensure it contains exactly what you intended
- Use `git commit --amend` to fix the last commit if needed (before pushing)