# Create GitHub Issue

Create a GitHub issue in the current repository with proper templates.

## Usage
- `/gh-issue` - Create a custom issue in current repo
- `/gh-issue enhancement` - Create an enhancement issue with template
- `/gh-issue bug` - Create a bug issue with template

## Parameters
- `type` (optional): `enhancement`, `bug`, or omit for custom

## Examples
- `/gh-issue` - Create custom issue
- `/gh-issue enhancement` - Create enhancement with template
- `/gh-issue bug` - Create bug report with template

## Implementation

Check if in a git repository, then use `gh issue create` with interactive prompts or templates based on the issue type.