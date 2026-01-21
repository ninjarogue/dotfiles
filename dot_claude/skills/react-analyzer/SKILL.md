---
name: react-analyzer
description: Analyzes React components to reveal their state machine behavior, stripping implementation noise to show inputs, state, derived values, effects, handlers, and conditional rendering. Use when asked to analyze, break down, or explain a React component, or when someone asks "what does this component do" or "show me the state machine."
---

# React Component Analyzer

Extract the signal from React components - see them as state machines, not JSX soup.

## Quick Start

Given a component file or code, analyze and output:

1. **One-sentence purpose**
2. **6-element breakdown** (tables)
3. **State machine diagram** (ASCII)
4. **Data flow summary**

## Analysis Framework

Extract these 6 elements systematically:

### 1. Inputs (what flows IN)

| Source | Examples |
|--------|----------|
| Props | From TypeScript interface/type |
| External hooks | `useContext`, `useTranslation`, `useRouter`, custom hooks |

**NOT inputs:** `useState`, `useCallback`, `useMemo` (these are internal)

### 2. State (what this component OWNS)

Extract from `useState` and `useReducer`:

| Name | Type | Initial | Purpose |
|------|------|---------|---------|

### 3. Derived (computed each render)

Variables calculated from state/props - NOT state, just computed:

```tsx
const isEmpty = query.length === 0;
const filteredItems = items.filter(x => x.active);
```

| Name | Expression | Purpose |
|------|------------|---------|

### 4. Effects (side effects synced to state)

`useEffect` blocks - what external system does each sync with?

| Dependencies | External System | Action |
|--------------|-----------------|--------|

Common: API calls, localStorage, DOM, subscriptions, timers

### 5. Handlers (user actions → state changes)

Trace: **event → handler → setState**

| Handler | Trigger | State Changes |
|---------|---------|---------------|

### 6. Output (conditional rendering)

What renders based on state? Look for:
- `{condition && <X/>}`
- Ternaries `{a ? <X/> : <Y/>}`
- Early returns

| Condition | Renders |
|-----------|---------|

## Output Template

```markdown
## Component: [Name]

### Purpose
[One sentence - what does this component do in plain English]

### Inputs
| Source | Name | Type | From |
|--------|------|------|------|
| prop | ... | ... | parent |
| hook | ... | ... | useContext/etc |

### State
| Name | Type | Initial | Purpose |
|------|------|---------|---------|

### Derived
| Name | Expression | Purpose |
|------|------------|---------|

### Effects
| Dependencies | External System | Action |
|--------------|-----------------|--------|

### Handlers
| Handler | Trigger | State Changes |
|---------|---------|---------------|

### Conditional Rendering
| Condition | Renders |
|-----------|---------|

### State Machine

┌──────────────┐  [event]  ┌──────────────┐
│  STATE_A     │ ────────► │  STATE_B     │
│              │           │              │
│ [renders X]  │ ◄──────── │ [renders Y]  │
└──────────────┘  [event]  └──────────────┘

### Data Flow
props → state → derived → output
```

## State Machine Diagram Rules

1. **Name the states** - Convert booleans to named states:
   - `isOpen: boolean` → "Open" and "Closed"
   - `isLoading: boolean` → "Idle" and "Loading"
   - `status: 'idle' | 'pending' | 'success'` → three named states

2. **Show transitions** - Label arrows with the triggering event

3. **Show renders** - Note what UI appears in each state

4. **Keep it simple** - One diagram per major state variable, or combine if tightly coupled

## Example Analysis

Input component:

```tsx
function SearchBox({ onSearch }: { onSearch: (q: string) => Promise<void> }) {
  const [query, setQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const isEmpty = query.length === 0;

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    await onSearch(query);
    setIsLoading(false);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      {isLoading ? <Spinner /> : <Button disabled={isEmpty}>Search</Button>}
    </form>
  );
}
```

Output:

```markdown
## Component: SearchBox

### Purpose
Text input that triggers a search callback with loading feedback.

### Inputs
| Source | Name | Type | From |
|--------|------|------|------|
| prop | onSearch | (q: string) => Promise<void> | parent |

### State
| Name | Type | Initial | Purpose |
|------|------|---------|---------|
| query | string | '' | Current search text |
| isLoading | boolean | false | Search in progress |

### Derived
| Name | Expression | Purpose |
|------|------------|---------|
| isEmpty | query.length === 0 | Disable button when empty |

### Effects
(none)

### Handlers
| Handler | Trigger | State Changes |
|---------|---------|---------------|
| onChange | input typing | query → e.target.value |
| handleSubmit | form submit | isLoading: false → true → false |

### Conditional Rendering
| Condition | Renders |
|-----------|---------|
| isLoading | Spinner |
| !isLoading | Button (disabled if isEmpty) |

### State Machine

┌──────────────┐  submit   ┌──────────────┐
│    IDLE      │ ────────► │   LOADING    │
│              │           │              │
│ [Button]     │ ◄──────── │ [Spinner]    │
└──────────────┘  complete └──────────────┘
       │
       │ typing
       ▼
  query updates
  isEmpty recalculates
  Button disabled if empty

### Data Flow
onSearch (prop) → query, isLoading (state) → isEmpty (derived) → Button/Spinner (output)
```

## Guidelines

- **Filter noise** - Ignore CSS, styling props, complex JSX nesting
- **Trace ownership** - Distinguish "state we own" vs "state from hooks"
- **Keep it terse** - Quick reference, not documentation
- **Show the machine** - Every component is a state machine - make it visible

## Usage

Provide either:
- A file path to read
- Component code directly

Then follow this framework to extract and format the analysis.
