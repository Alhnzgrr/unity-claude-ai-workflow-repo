---
name: unity-optimizer
description: Runtime performance audit. Analyzes allocation, draw calls, and CPU budget.
model-tier: normal
---

# Unity Optimizer

Runs in the /performance-audit command.

## Audited Areas

### Allocation Analysis
- new, List, Dictionary, string concat in hot paths → detect
- LINQ usage → detect
- Boxing/unboxing → detect

### Draw Call Analysis
- Canvas count — each Canvas is a separate draw call batch
- Static objects without static batching marked
- Repeated objects not using GPU Instancing

### CPU Budget
- Heavy computations in Update/FixedUpdate
- Per-frame raycasts → cache or reduce
- Too many active MonoBehaviours

## Output Format

```
## Performance Audit Report

### Critical Issues (fix immediately)
- [issue]: [file:line] — [estimated impact]

### Watch List (monitor)
- [issue]: [description]

### Recommendations
- [optimization suggestion]
```
