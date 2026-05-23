# /orchestrate

Executes `docs/WORKFLOW.md` phase by phase.

## Usage

```text
/orchestrate
```

## Prerequisite

`docs/WORKFLOW.md` must exist. If not, run `/plan-workflow`.

## Workflow

### Step 0 - Initialization

1. Read `docs/WORKFLOW.md`.
2. Scan existing code and assets relevant to the workflow.
3. Show a pre-scan report with already implemented systems.

### SCOPE_GATE

```text
WORKFLOW.md loaded.
Phases: [N]
Total tasks: [M]
Pre-scan: [systems already present]

Type "go" to start.
```

### Step 1 - Phase Loop

For each phase:

```text
PHASE [N]: [Phase Name]
```

Task execution uses the compact agent chain:

```text
project-architect when design/research is needed
test-validator when tests or validation are needed
unity-implementer for implementation
code-reviewer for review
performance-auditor only for performance-sensitive work
docs-maintainer only for documentation updates
```

Run `/validate` at the end of each phase.

### Phase Gate

```text
Phase [N] complete.
Proceed to next phase? (yes / no / stop)
```

### Step 2 - Completion

Append to `docs/EVENTS.jsonl`:

```json
{"event":"ORCHESTRATION_COMPLETED","timestamp":"...","phases":[N],"tasks":[M]}
```

```text
ORCHESTRATION COMPLETE
Phases: [N]
Tasks: [M]
```

