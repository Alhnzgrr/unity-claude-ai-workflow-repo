# /fix

Bug fix pipeline: scout → fixer → test → reviewer → committer.

## Usage

```
/fix <error description or stack trace>
```

## Workflow

### Step 0 — Calculate Complexity

- Is there a stack trace? → is the root cause clear?
- How many files are affected?
- Complexity < 0.2 → suggest `/fix-lite`
- Complexity unclear → suggest `/fix-deep`

### ▶ SCOPE_GATE

```
Bug: [description]
Estimated affected files: [list]
Complexity: [0.0–1.0]

Type "go" to continue.
```

### Step 1 — unity-scout + unity-fixer (parallel, complexity ≥ 0.4)

- `unity-scout`: dependency map, affected files
- `unity-fixer`: root cause analysis

**▶ BREAKING_GATE** (if 3+ files affected):
```
This fix affects [N] files. Wide-scope change.
Type "go" to continue.
```

### Step 2 — tester

`tester` agent: write a regression test (a test that reproduces the bug).

### Step 3 — unity-coder or unity-fixer

Apply the fix. Regression test must pass.

### Step 4 — unity-verifier

Compile + run all tests.

### Step 5 — Reviewer (lean/full mode)

Spawn `unity-reviewer`.

**▶ QUALITY_GATE** (if CHANGES NEEDED).

### Step 6 — committer

**▶ COMMIT_GATE** → `committer` creates the commit.
