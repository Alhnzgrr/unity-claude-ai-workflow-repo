# /implement

Implementation pipeline: test -> implement -> validate -> review -> optional commit.

## Usage

```text
/implement <task description>
```

## Workflow

### Step 0 - Preparation

1. Read `production/review-mode.txt`.
2. Read `.claude/project-config.json`.
3. Estimate complexity and affected files.
4. Select the required skills before spawning agents.

### SCOPE_GATE

```text
Task: [task description]
Complexity: [0.0-1.0]
Files affected: [estimate]
Review mode: [solo/lean/full]

Type "go" to continue.
```

### Step 1 - test-validator

Spawn `test-validator` when tests are expected:

- Write focused failing tests first when the task fits TDD.
- Choose EditMode, PlayMode programmatic, or PlayMode scene tests.
- Skip test generation only when the change is documentation-only or explicitly exploratory.

### Step 2 - unity-implementer

Spawn `unity-implementer`:

- Implement the smallest coherent change.
- Use project DI, async, input, serialization, and Unity lifecycle rules.
- Use Unity MCP for scene/prefab/asset wiring when needed.

### Step 3 - test-validator

Spawn `test-validator`:

- Compile check.
- Run relevant tests and hook checks.
- Send failures back to `unity-implementer` for at most two fix passes.

### Step 4 - code-reviewer

- `solo`: skip unless the change is risky.
- `lean`: run normal review.
- `full`: run stricter review depth in the same `code-reviewer` agent.

### QUALITY_GATE

```text
Reviewer returned CHANGES NEEDED.
fix  -> continue fixing
skip -> skip review
stop -> halt the process
```

### Step 5 - Commit

Ask for COMMIT_GATE before committing. The main Claude session creates the commit; no separate commit agent is required.

```text
Staged files:
- [file list]

About to commit. Do you approve? (go / no)
```

## Output

```text
IMPLEMENT COMPLETE
Tests: [N] passed / not run
Files: [M] files changed
Commit: [hash or none]
```

