---
name: plan-explorer
description: Generate interactive HTML playground from implementation plans. Use after creating a plan to help the user visualize steps, components, and file changes. Triggers when user says "explore plan", "visualize plan", "plan playground", or after writing a plan when user wants to review it interactively. Helps users control implementation scope, add comments, and understand dependencies.
---

# Plan Explorer

Generate a self-contained HTML playground from an implementation plan. The playground lets users:

1. **Visualize** all steps, components, and files in an interactive tree
2. **Control scope** by toggling which steps to implement
3. **Add comments** directly on steps for Claude to review
4. **Copy prompt** with their modifications back to Claude

## When to Generate

After writing an implementation plan, offer: "Want me to generate a plan explorer so you can review and adjust this interactively?"

## Generating the Playground

1. Parse the plan into structured data with implementation details:

```javascript
const planData = {
  title: "Feature name",
  steps: [
    {
      id: 1,
      title: "Step title",
      description: "What this step does",
      files: ["path/to/file.ts", "path/to/other.ts"],
      components: ["ComponentName", "HookName"],
      dependencies: [0], // step IDs this depends on
      estimatedLines: 50,
      type: "create" | "modify" | "delete",
      implementation: {
        pattern: "Context + useReducer",
        decisions: [
          "JWT stored in httpOnly cookie for security",
          "Auto-refresh token 5min before expiry"
        ],
        pseudocode: `const useAuth = () => {
  const [state, dispatch] = useReducer(authReducer, initial)
  // persist session, expose login/logout/user
}`,
        apis: ["POST /api/auth/login", "POST /api/auth/refresh"]
      }
    }
  ]
};
```

### Implementation Details Field

Always include `implementation` for each step:

| Field | Purpose | Example |
|-------|---------|---------|
| `pattern` | Design pattern or approach | "Context + useReducer", "Server Action", "REST API" |
| `decisions` | Key choices with rationale | ["Use Zod for validation - already in codebase"] |
| `pseudocode` | Code sketch showing structure | Function signatures, key logic flow |
| `apis` | External calls, endpoints | ["GET /api/users", "Stripe.charges.create()"] |

2. Generate HTML using the template pattern in `assets/plan-explorer-template.html`

3. Save to `/tmp/plan-explorer-{timestamp}.html` and open with `xdg-open`

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│  PLAN: [Title]                    [Presets ▾] [Reset]       │
├────────────────────────────┬────────────────────────────────┤
│  STEPS                     │  DETAILS                       │
│  ┌──────────────────────┐  │  ┌──────────────────────────┐  │
│  │ ☑ 1. Add types       │  │  │ Files:                   │  │
│  │   └→ 2. Create hook  │  │  │ • src/types.ts (create)  │  │
│  │ ☑ 3. Update comp     │  │  │                          │  │
│  │ ☐ 4. Add tests       │  │  │ ▼ Implementation Details │  │
│  │ ☐ 5. Update docs     │  │  │ ┌──────────────────────┐ │  │
│  └──────────────────────┘  │  │ │ Pattern: Context +   │ │  │
│                            │  │ │   useReducer         │ │  │
│  Scope: ━━━━●━━ 3/5        │  │ │ Decisions:           │ │  │
│  ~120 lines affected       │  │ │ • JWT in httpOnly    │ │  │
│                            │  │ │ • Auto-refresh 5min  │ │  │
│                            │  │ │ Pseudocode:          │ │  │
│                            │  │ │ ```                  │ │  │
│                            │  │ │ const useAuth = ()   │ │  │
│                            │  │ │ ```                  │ │  │
│                            │  │ └──────────────────────┘ │  │
│                            │  │ [Add Comment]            │  │
├────────────────────────────┴────────────────────────────────┤
│  COMMENTS                                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Step 2: "Use React Query instead of custom hook"       │ │
│  └────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  PROMPT OUTPUT                                         [Copy]│
└─────────────────────────────────────────────────────────────┘
```

## Key Features

### Step Tree with Dependencies
- Show dependency arrows between steps
- Grayed-out steps when dependencies unchecked
- Click step to show details panel

### Implementation Details (Expandable)
- Collapsible section in details panel
- Shows pattern, decisions, pseudocode, APIs
- User can drill into any step to see HOW it'll be implemented
- Collapsed by default, expand where uncertain

### Scope Control
- Checkbox per step to include/exclude
- Slider for quick "implement first N steps"
- Presets: "Minimal" (first step), "Core" (no tests/docs), "Full"

### Comments System
- Click "Add Comment" on any step
- Comments appear in list and prompt output
- Edit/delete existing comments
- Comments can reference specific implementation details

### Prompt Output
- Natural language, not value dump
- Only mentions selected steps and non-default choices
- Includes all comments inline
- Copy button with feedback

## State Management

```javascript
const state = {
  steps: planData.steps.map(s => ({
    ...s,
    enabled: true,
    comment: ""
  })),
  selectedStep: 0,
  presets: { minimal: [0], core: [0,1,2], full: "all" }
};

function updateAll() {
  renderStepTree();
  renderDetails();
  renderComments();
  updatePrompt();
}
```

## Prompt Output Format

```javascript
function updatePrompt() {
  const enabled = state.steps.filter(s => s.enabled);
  const withComments = state.steps.filter(s => s.comment);

  let prompt = `Implement steps ${enabled.map(s => s.id).join(", ")} from the plan.`;

  if (withComments.length) {
    prompt += "\n\nComments:\n";
    withComments.forEach(s => {
      prompt += `- Step ${s.id} (${s.title}): ${s.comment}\n`;
    });
  }

  const skipped = state.steps.filter(s => !s.enabled);
  if (skipped.length) {
    prompt += `\nSkip: ${skipped.map(s => s.title).join(", ")}`;
  }

  promptEl.textContent = prompt;
}
```

## After Generating

1. Open the HTML file: `xdg-open /tmp/plan-explorer-{timestamp}.html`
2. Tell user: "Plan explorer opened in browser. Toggle steps, add comments, then copy the prompt back here."
3. When user pastes modified prompt, follow their adjustments exactly
