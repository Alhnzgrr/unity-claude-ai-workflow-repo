# /implement

TDD pipeline: test → coder → verifier → reviewer → committer.

## Usage

```
/implement <task description>
```

## Workflow

### Step 0 — Preparation

1. Read `production/review-mode.txt`
2. Read `project-config.json` (DI, async, input type)
3. Calculate complexity (0.0–1.0)
4. Determine model tier

### ▶ SCOPE_GATE

```
Task: [task description]
Complexity: [0.0–1.0]
Files affected: [estimate]
Review mode: [solo/lean/full]

Type "go" to continue.
```

On receiving `go`, create `.claude/state/gate-cleared`.

### Step 1 — tester (isolated subagent)

Spawn `tester` agent:
- Write the test file
- Tests MUST FAIL (no implementation yet)
- Test type: EditMode / PlayMode (based on complexity)

### Step 2 — unity-coder or coder

- Complexity ≥ 0.4 or Unity API required → `unity-coder`
- Pure C# → `coder`
- Write minimal implementation to pass the tests

### Step 3 — unity-verifier

Spawn `unity-verifier`:
- Compile check
- Run tests
- Failure → send back to unity-coder (max 2 passes)

### Step 4 — Reviewer

- review-mode == `solo` → skip this step
- review-mode == `lean` or `full` → spawn `unity-reviewer`

**▶ QUALITY_GATE** (if CHANGES NEEDED):
```
Reviewer returned CHANGES NEEDED.
fix → continue fixing
skip → skip review
stop → halt the process
```

### Step 5 — unity-developer (full mode)

- review-mode == `full` → spawn `unity-developer`
- Otherwise skip

### Step 6 — silent-failure-hunter

Spawn `silent-failure-hunter`:
- Check for exception swallowing, async void, event leaks

### Step 7 — committer

**▶ COMMIT_GATE**:
```
Staged files:
- [file list]

About to commit. Do you approve? (go / no)
```

`go` → `committer` agent creates the commit.

### Cleanup

Delete `.claude/state/gate-cleared`.

## Output

```
✅ IMPLEMENT COMPLETE
   Tests: [N] passed
   Files: [M] files changed
   Commit: [commit hash]
```
