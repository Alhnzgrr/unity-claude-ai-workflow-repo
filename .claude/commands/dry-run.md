# /dry-run

Previews WORKFLOW.md without executing it. Shows which agents will run in which order.

## Usage

```
/dry-run
```

## Workflow

### Step 1 — Read WORKFLOW.md

Read `docs/WORKFLOW.md`.

### Step 2 — Create Execution Plan

For each phase and task:
- Which agent will be used
- Which tasks will run in parallel (parallel_group)
- Estimated file changes
- Where Director Gates will be triggered

### Step 3 — Show Report

```
## Dry Run Report — WORKFLOW.md

### Phase 1: Foundation (2 tasks, parallel)
  [parallel_group: foundation]
  ├── Task 1.1 → unity-implementer → EventBus.cs
  └── Task 1.2 → unity-implementer → UnityLogger.cs
  Gate: SCOPE_GATE (at phase start)

### Phase 2: Core Systems (3 tasks)
  ├── Task 2.1 → unity-implementer → AudioService + tests
  ├── Task 2.2 → unity-implementer → PlayerService + tests
  └── Task 2.3 → unity-implementer → EnemyService + tests
  Gate: SCOPE_GATE + COMMIT_GATE

Total: [N] tasks, [M] agent spawns, [K] Director Gates

To execute: /orchestrate
```

NO changes are made — only the plan is shown.
