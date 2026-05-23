# /context-prime

Brings Claude into the project context at the start of a session.

## Usage

```
/context-prime
```

## Workflow

### Step 1 — Read Core Files

- `project-config.json` → DI, async, input, feature flags
- `production/review-mode.txt` → review mode
- `docs/TDD.md` (if present) → technical design summary
- `.claude/state/checkpoint.md` (if present) → last session summary
- `docs/WORKFLOW.md` (if present) → which phase/task are we on?

### Step 2 — Context Summary

```
## Project Context

**DI:** vcontainer | **Async:** UniTask | **Input:** New Input System
**ECS:** false | **Addressables:** false | **XR:** false
**Review Mode:** lean

**TDD Status:** [summary]
**WORKFLOW Status:** Phase [N], Task [M]
**Last Checkpoint:** [date and summary]

Ready. What would you like to do?
```
