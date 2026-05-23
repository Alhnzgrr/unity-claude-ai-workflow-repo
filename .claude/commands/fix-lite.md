# /fix-lite

Fast path for obvious low-risk bugs.

## Usage

```text
/fix-lite <brief error description>
```

## When to Use

- Obvious `NullReferenceException`
- Typo
- Off-by-one error
- Wrong operator
- Small local edit with clear cause

## When Not to Use

Use `/fix` or `/fix-deep` when the root cause is unclear, multiple files are affected, or architecture may be involved.

## Workflow

### Step 1 - unity-implementer

Spawn `unity-implementer`:

- Read the relevant file first.
- Apply the smallest local fix.

### Step 2 - test-validator

Run compile and relevant tests when available.

### Step 3 - Commit

For a low-risk fix, the main Claude session may create a semantic commit after reporting the staged files.

## Output

```text
FIX-LITE COMPLETE
[file:line] fixed
Commit: [hash or none]
```

