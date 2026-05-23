# /fix-deep

Evidence-first fix. No fix is made until the root cause is proven.

## Usage

```
/fix-deep <unclear or intermittent error description>
```

## When to Use

- Root cause unclear
- Intermittent (happens occasionally)
- Insufficient stack trace
- "Sometimes works" issues

## Workflow

### Step 1 — Log Intake

Collect existing logs and error messages:
- Stack trace
- Unity Console output
- Reproduction steps

### Step 2 — Generate Hypotheses

With `unity-scout` + `unity-fixer`, produce a minimum of 2 hypotheses:
```
Hypothesis 1: [cause] — Evidence: [what we expect to see]
Hypothesis 2: [cause] — Evidence: [what we expect to see]
```

### Step 3 — Debug Injection

Add temporary debug logs to gather evidence:
```csharp
Debug.Log($"[DEBUG] {nameof(MyMethod)}: value={value}, state={_state}");
```

To the user: "Run the game, test this scenario, paste the log here."

### Step 4 — Evidence Gate

Once the log is received, evaluate the hypotheses:
- Hypothesis confirmed? → Apply fix
- Not confirmed → New hypothesis

**No fix is made until the root cause is proven.**

### Step 5 — Fix (With Proven Root Cause)

Continue with the `/fix` pipeline (test → coder → verify → review → commit).

### Step 6 — Clean Up Debug Code

```bash
git diff -- "*.cs" | grep "DEBUG"
```

Remove debug log lines, create commit.
