# /fix

Bug fix pipeline: investigate -> fix -> regression test -> validate -> review -> optional commit.

## Usage

```text
/fix <error description or stack trace>
```

## Workflow

### Step 0 - Triage

- If the root cause is unclear, spawn `project-architect` for dependency mapping and hypotheses.
- If the root cause is clear, go directly to `unity-implementer`.
- If the change is risky or wide-scope, stop at SCOPE_GATE.

### SCOPE_GATE

```text
Bug: [description]
Estimated affected files: [list]
Complexity: [0.0-1.0]

Type "go" to continue.
```

### Step 1 - project-architect

Use only when needed:

- Map affected systems.
- Identify likely root cause.
- Define the smallest safe fix boundary.

### Step 2 - unity-implementer

Spawn `unity-implementer`:

- Apply the root-cause fix.
- Avoid broad refactors unless the bug cannot be fixed safely without them.
- Use MCP or manual Unity Editor steps for scene/prefab wiring.

### Step 3 - test-validator

Spawn `test-validator`:

- Add or update a regression test when practical.
- Compile and run relevant tests.
- Run hook checks when repository files changed.

### Step 4 - code-reviewer

Run `code-reviewer` in lean/full modes:

- Check the fix for regressions.
- Check lifecycle, async, event, and serialization risks.
- Check whether test coverage is enough for the bug.

### Step 5 - Commit

Ask for COMMIT_GATE before committing. The main Claude session creates the commit.

