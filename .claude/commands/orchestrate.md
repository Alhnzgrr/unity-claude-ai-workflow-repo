# /orchestrate

Executes WORKFLOW.md phase by phase. Fully automated pipeline.

## Usage

```
/orchestrate
```

## Prerequisite

`docs/WORKFLOW.md` must exist. If not, run `/plan-workflow`.

## Workflow

### Step 0 — Initialization

1. Read `docs/WORKFLOW.md`
2. Scan `Assets/_Framework/` and `Assets/_GameFolders/` — detect existing code
3. Show Pre-Scan report (which code already exists)

### ▶ SCOPE_GATE

```
WORKFLOW.md loaded.
Phases: [N]
Total tasks: [M]

Pre-Scan: [systems already present]

Type "go" to start.
```

### Step 1 — Phase Loop

For each phase:

```
=== PHASE [N]: [Phase Name] ===
```

**Parallel task detection:**
Tasks in the same `parallel_group` → spawn at the same time
Conflicting output files → run sequentially

**Task execution:**
→ tester → coder/unity-coder → verifier → reviewer → committer

**Automatic end-of-phase quality:**
→ `/ralph` (verify-fix loop)
→ `silent-failure-hunter`
→ `/validate`

**Phase Gate (manual):**
```
Phase [N] complete.
Proceed to next phase? (yes / no / stop)
```

### Step 2 — Completion

Append to `docs/EVENTS.jsonl`:
```json
{"event":"ORCHESTRATION_COMPLETED","timestamp":"...","phases":[N],"tasks":[M]}
```

Delete `.claude/state/gate-cleared`.

```
✅ ORCHESTRATION COMPLETE
   Phases: [N]
   Tasks: [M]
   Commits: [K]
```
