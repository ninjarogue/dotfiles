---
name: work-issue
description: End-to-end workflow for implementing a GitHub issue. Reads the issue, investigates the codebase, implements the solution, and creates a PR. Use when user says "work on issue #123", "implement issue #123", or "fix issue #123 end to end".
---

# Work Issue End-to-End

Complete workflow from issue to pull request.

## Workflow Overview

1. **Read** - Understand what's being asked
2. **Investigate** - Find relevant code and understand the context
3. **Plan** - Design the implementation approach
4. **Implement** - Write the code
5. **Test** - Verify the changes work
6. **Commit** - Create atomic commits
7. **PR** - Submit the pull request

## Phase 1: Read the Issue

```bash
gh issue view <number> --json title,body,state,labels,comments,url
```

Extract and confirm:
- Clear understanding of requirements
- Acceptance criteria
- Any constraints or preferences mentioned

## Phase 2: Investigate

Delegate to the `investigate-issue` agent for deep codebase analysis:

```
Task(subagent_type: "investigate-issue", prompt: "Investigate issue #<number> - <title>")
```

Review the findings before proceeding.

## Phase 3: Plan

Before writing code:
- Identify all files that need changes
- Determine the order of changes
- Consider edge cases and error handling
- Note any tests that need to be added/updated

Present the plan to the user for approval if the changes are significant.

## Phase 4: Implement

Write the code following project conventions:
- Match existing code style
- Keep changes focused on the issue
- Don't refactor unrelated code

## Phase 5: Test

- Run existing tests to ensure nothing broke
- Add new tests if appropriate
- Manual verification if applicable

```bash
# Check for test commands in package.json or README
# Run the appropriate test suite
```

## Phase 6: Commit

Use the **commit** skill to create atomic commits with conventional format.

## Phase 7: Create PR

Use the **submit-pr** skill to create the pull request. Ensure the PR references `Closes #<issue-number>`.

## Checkpoints

Pause and confirm with the user at these points:
- After investigation, before implementation (for significant changes)
- After implementation, before committing (if requested)
- Before creating the PR

## Notes

- Stay focused on the issue scope - don't add unrequested features
- If the issue is unclear, ask for clarification before implementing
- If you discover the issue is more complex than expected, discuss with the user
