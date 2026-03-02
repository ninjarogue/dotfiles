---
name: code-flow-diagram
description: Generate interactive HTML flow diagrams that visualize code execution order with inputs, outputs, and implementation details. Use when the user asks to "visualize code flow", "show me the execution order", "create a flow diagram for this code", "help me understand this script", "trace data through functions", or wants to build a mental model of sequential code. Ideal for scripts, build tools, data pipelines, CLI tools, or any code with clear execution flow.
---

# Code Flow Diagram

Generate a single-file HTML visualization showing code execution as a vertical flow with expandable details.

## Output Format

Each step shows at a glance:
```
[step number + function]  [input] → [output]
```

Click to expand:
- **Implementation** — actual code
- **Inputs** — each parameter with type and example
- **Outputs** — what it returns/produces
- **Watch out** — edge cases, gotchas
- **Comments / Questions** — per-step notes panel for reviewer feedback (persistent)

## Visual Structure

- **Normal steps**: No indent, gray left border
- **Loop body**: Indented 24px, purple left border, labeled "⟳ For each X"
- **Conditional**: Indented 48px, orange left border, labeled "If condition"
- **Nested calls**: Indented 48px, use "↳" prefix in step name

## Step Data Structure

```javascript
{
  id: 'uniqueId',
  name: '1. <code>functionName()</code>',
  desc: 'Brief description',
  input: 'shortInputLabel',
  output: 'shortOutputLabel',
  code: `actual implementation`,
  inputs: [
    { key: 'paramName', type: 'string', example: '"value"' }
  ],
  outputs: [
    { key: 'returnValue', type: 'object', example: '{ result }' }
  ],
  gotchas: ['Edge case or note'],
  // Optional: for section labels
  loopLabel: 'For each locale',      // shows "⟳ For each locale"
  conditionalLabel: 'If override exists'
}
```

## Process

1. Read the target file
2. Trace execution from entry point through all calls
3. Number steps in execution order (1, 2, 3...)
4. For each step identify:
   - Function name and purpose
   - Input parameters with realistic examples
   - Output/return value with examples
   - Actual code implementation
   - Gotchas (edge cases, caveats, non-obvious behavior)
5. Mark loops and conditionals for visual grouping
6. Include a per-step `Comments / Questions` section (textarea + list) inside each step's expanded details that persists to `localStorage` keyed by `step.id`
7. Generate HTML file named `{filename}-flow.html`
8. Open in browser

## HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FILENAME Flow</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #e2e8f0; min-height: 100vh; padding: 24px; }
    h1 { font-size: 16px; color: #94a3b8; margin-bottom: 24px; text-transform: uppercase; letter-spacing: 0.05em; }
    .comments-help { font-size: 12px; color: #94a3b8; margin-bottom: 10px; }
    .comments-input { width: 100%; min-height: 84px; padding: 10px; border-radius: 6px; border: 1px solid #334155; background: #0f172a; color: #e2e8f0; font-size: 13px; resize: vertical; }
    .comments-actions { display: flex; gap: 8px; margin-top: 8px; }
    .comments-btn { border: 1px solid #334155; background: #0f172a; color: #e2e8f0; border-radius: 6px; padding: 6px 10px; font-size: 12px; cursor: pointer; }
    .comments-btn.primary { border-color: #3b82f6; color: #93c5fd; }
    .comments-btn:hover { background: #1e293b; }
    .comments-list { margin-top: 12px; display: grid; gap: 8px; }
    .comment-item { border: 1px solid #334155; border-radius: 6px; padding: 10px; background: #111827; }
    .comment-meta { font-size: 11px; color: #94a3b8; margin-bottom: 6px; display: flex; justify-content: space-between; gap: 8px; }
    .comment-text { white-space: pre-wrap; line-height: 1.5; font-size: 13px; color: #e2e8f0; }
    .comment-empty { font-size: 12px; color: #64748b; font-style: italic; }
    .comment-delete { border: none; background: transparent; color: #fca5a5; cursor: pointer; font-size: 11px; padding: 0; }
    .flow { display: flex; flex-direction: column; gap: 2px; max-width: 1000px; margin: 0 auto; }
    .step { display: grid; grid-template-columns: 220px 1fr 200px; gap: 16px; align-items: center; padding: 16px; background: #1e293b; border-radius: 8px; border-left: 4px solid #334155; cursor: pointer; transition: all 0.15s; }
    .step:hover { background: #273548; border-left-color: #3b82f6; }
    .step.expanded { border-left-color: #3b82f6; background: #1e3a5f; }
    .step.loop { margin-left: 24px; border-left-color: #8b5cf6; }
    .step.loop:hover { border-left-color: #a78bfa; }
    .step.conditional { margin-left: 48px; border-left-color: #f59e0b; opacity: 0.9; }
    .step.conditional:hover { border-left-color: #fbbf24; opacity: 1; }
    .step.nested { margin-left: 48px; border-left-color: #64748b; background: #172033; }
    .loop-label, .conditional-label { font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; padding: 8px 0; }
    .loop-label { color: #a78bfa; padding-left: 28px; }
    .conditional-label { color: #f59e0b; padding-left: 52px; }
    .step-name { font-weight: 600; font-size: 14px; color: #f1f5f9; }
    .step-name code { font-family: 'SF Mono', 'Consolas', monospace; background: #0f172a; padding: 2px 6px; border-radius: 4px; font-size: 13px; }
    .step-desc { font-size: 13px; color: #94a3b8; }
    .step-io { display: flex; gap: 8px; align-items: center; justify-content: flex-end; }
    .io-box { font-family: 'SF Mono', 'Consolas', monospace; font-size: 11px; padding: 6px 10px; border-radius: 4px; max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .io-in { background: #1e3a5f; color: #60a5fa; border: 1px solid #3b82f6; }
    .io-out { background: #14532d; color: #4ade80; border: 1px solid #22c55e; }
    .arrow { color: #64748b; font-size: 18px; }
    .connector { display: flex; justify-content: center; padding: 4px 0; }
    .connector-line { width: 2px; height: 20px; background: #334155; }
    .details { display: none; grid-column: 1 / -1; margin-top: 16px; padding-top: 16px; border-top: 1px solid #334155; }
    .step.expanded .details { display: block; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .detail-section { background: #0f172a; padding: 16px; border-radius: 8px; }
    .detail-section.full { grid-column: 1 / -1; }
    .detail-title { font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 10px; }
    .detail-code { font-family: 'SF Mono', 'Consolas', monospace; font-size: 12px; line-height: 1.6; color: #a5f3fc; white-space: pre; overflow-x: auto; background: #0b1220; border: 1px solid #1f2937; border-radius: 6px; padding: 12px; }
    .detail-item { display: flex; gap: 12px; padding: 6px 0; border-bottom: 1px solid #1e293b; }
    .detail-item:last-child { border-bottom: none; }
    .detail-key { color: #f472b6; font-family: 'SF Mono', monospace; font-size: 12px; min-width: 100px; }
    .detail-type { color: #64748b; font-size: 11px; font-family: 'SF Mono', monospace; }
    .detail-example { color: #fbbf24; font-family: 'SF Mono', monospace; font-size: 11px; background: #1e293b; padding: 2px 6px; border-radius: 3px; }
    .gotcha { color: #fbbf24; font-size: 12px; padding: 4px 0; display: flex; gap: 8px; }
    .gotcha::before { content: "⚠"; flex-shrink: 0; }
  </style>
</head>
<body>
  <h1>FILENAME → Data Flow</h1>
  <div class="flow" id="flow"></div>
  <script>
    const steps = STEPS_JSON;
    const loopSteps = LOOP_STEPS_JSON;
    const conditionalSteps = CONDITIONAL_STEPS_JSON;
    const nestedSteps = NESTED_STEPS_JSON;
    const commentsStorageKey = 'FILENAME-flow-comments-by-step';
    let commentsByStep = {};

    function render() {
      const flow = document.getElementById('flow');
      flow.innerHTML = steps.map((step, i) => {
        const isLoop = loopSteps.includes(step.id);
        const isConditional = conditionalSteps.includes(step.id);
        const isNested = nestedSteps.includes(step.id);
        let classes = 'step';
        if (isConditional) classes += ' conditional';
        else if (isNested) classes += ' nested';
        else if (isLoop) classes += ' loop';
        let prefix = '';
        if (step.loopLabel) prefix = `<div class="loop-label">⟳ ${step.loopLabel}</div>`;
        if (step.conditionalLabel) prefix = `<div class="conditional-label">${step.conditionalLabel}</div>`;
        return `
        ${prefix}
        <div class="${classes}" data-id="${step.id}" onclick="toggleStep('${step.id}')">
          <div>
            <div class="step-name">${step.name}</div>
            <div class="step-desc">${step.desc}</div>
          </div>
          <div class="step-io">
            <div class="io-box io-in">${step.input}</div>
            <span class="arrow">→</span>
            <div class="io-box io-out">${step.output}</div>
          </div>
          <div></div>
          <div class="details">
            <div class="detail-grid">
              <div class="detail-section full">
                <div class="detail-title">Implementation</div>
                <pre class="detail-code"><code>${escapeHtml(step.code)}</code></pre>
              </div>
              <div class="detail-section">
                <div class="detail-title">Inputs</div>
                ${step.inputs.map(inp => `
                  <div class="detail-item">
                    <div class="detail-key">${inp.key}</div>
                    <div>${inp.type ? `<span class="detail-type">${inp.type}</span> ` : ''}<span class="detail-example">${inp.example}</span></div>
                  </div>
                `).join('')}
              </div>
              <div class="detail-section">
                <div class="detail-title">Outputs</div>
                ${step.outputs.map(out => `
                  <div class="detail-item">
                    <div class="detail-key">${out.key}</div>
                    <div>${out.type ? `<span class="detail-type">${out.type}</span> ` : ''}<span class="detail-example">${out.example}</span></div>
                  </div>
                `).join('')}
              </div>
              ${step.gotchas.length ? `
                <div class="detail-section full">
                  <div class="detail-title">Watch out</div>
                  ${step.gotchas.map(g => `<div class="gotcha">${g}</div>`).join('')}
                </div>
              ` : ''}
              <div class="detail-section full">
                <div class="detail-title">Comments / Questions</div>
                <p class="comments-help">Notes for this step. Saved locally in your browser.</p>
                <textarea class="comments-input" data-comment-input="${step.id}" placeholder="Add a comment or question..."></textarea>
                <div class="comments-actions">
                  <button type="button" class="comments-btn primary" onclick="addStepComment('${step.id}')">Save Comment</button>
                  <button type="button" class="comments-btn" onclick="clearStepComments('${step.id}')">Clear</button>
                </div>
                <div class="comments-list" data-comments-list="${step.id}"></div>
              </div>
            </div>
          </div>
        </div>
        ${i < steps.length - 1 ? '<div class="connector"><div class="connector-line"></div></div>' : ''}
      `}).join('');
    }
    function loadComments() {
      try {
        const raw = localStorage.getItem(commentsStorageKey);
        commentsByStep = raw ? JSON.parse(raw) : {};
        if (!commentsByStep || typeof commentsByStep !== 'object') commentsByStep = {};
      } catch {
        commentsByStep = {};
      }
    }

    function saveComments() {
      localStorage.setItem(commentsStorageKey, JSON.stringify(commentsByStep));
    }

    function getStepComments(stepId) {
      const list = commentsByStep[stepId];
      return Array.isArray(list) ? list : [];
    }

    function renderStepComments(stepId) {
      const list = document.querySelector(`[data-comments-list="${stepId}"]`);
      if (!list) return;
      const comments = getStepComments(stepId);
      if (!comments.length) {
        list.innerHTML = '<div class="comment-empty">No comments yet.</div>';
        return;
      }

      list.innerHTML = comments
        .map((comment) => `
          <div class="comment-item">
            <div class="comment-meta">
              <span>${escapeHtml(comment.createdAt)}</span>
              <button type="button" class="comment-delete" onclick="deleteStepComment('${stepId}', '${comment.id}')">Delete</button>
            </div>
            <div class="comment-text">${escapeHtml(comment.text)}</div>
          </div>
        `)
        .join('');
    }

    function renderAllStepComments() {
      for (const step of steps) {
        renderStepComments(step.id);
      }
    }

    function addStepComment(stepId) {
      const input = document.querySelector(`[data-comment-input="${stepId}"]`);
      if (!input) return;
      const text = input.value.trim();
      if (!text) return;
      const comments = getStepComments(stepId);
      comments.unshift({
        id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
        text,
        createdAt: new Date().toLocaleString(),
      });
      input.value = '';
      commentsByStep[stepId] = comments;
      saveComments();
      renderStepComments(stepId);
    }

    function deleteStepComment(stepId, id) {
      const comments = getStepComments(stepId).filter((comment) => comment.id !== id);
      commentsByStep[stepId] = comments;
      saveComments();
      renderStepComments(stepId);
    }

    function clearStepComments(stepId) {
      commentsByStep[stepId] = [];
      saveComments();
      renderStepComments(stepId);
    }

    function toggleStep(id) { document.querySelector(`[data-id="${id}"]`).classList.toggle('expanded'); }
    function escapeHtml(str) { return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); }
    loadComments();
    render();
    renderAllStepComments();
  </script>
</body>
</html>
```

Replace: `FILENAME`, `STEPS_JSON`, `LOOP_STEPS_JSON`, `CONDITIONAL_STEPS_JSON`, `NESTED_STEPS_JSON`

## Tips

- Use realistic example values from the actual codebase
- Include actual code, not pseudocode
- Gotchas = non-obvious things (edge cases, "why" explanations)
- Keep input/output labels short (shown in small boxes)
- For nested calls, use "↳" prefix: `↳ <code>helperFn()</code>`
