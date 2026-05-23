# /fix-lite

Fast path: NullRef, typo, obvious single-line fix.

## Usage

```
/fix-lite <brief error description>
```

## When to Use

- NullReferenceException (obvious cause)
- Typo
- Off-by-one
- Wrong operator (= instead of ==)

## When Not to Use

If root cause is unclear → use `/fix` or `/fix-deep`.

## Workflow

### Step 1 — unity-fixer-lite

Spawn `unity-fixer-lite`:
- Read the relevant file (for gateguard)
- Apply single-line fix

### Step 2 — unity-verifier

Compile + test check.

### Step 3 — committer (without COMMIT_GATE)

Automatic commit: `fix([scope]): [brief description]`

## Output

```
✅ FIX-LITE COMPLETE
   [file:line] fixed
   Commit: [hash]
```
