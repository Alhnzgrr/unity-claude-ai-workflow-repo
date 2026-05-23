# /fix-deep

Evidence-first debugging. No fix is made until the root cause is proven.

## Usage

```text
/fix-deep <unclear or intermittent error description>
```

## When to Use

- Root cause is unclear.
- Bug is intermittent.
- Stack trace is missing or points to a symptom.
- The issue sometimes works and sometimes fails.

## Workflow

### Step 1 - Log Intake

Collect existing evidence:

- Stack trace.
- Unity Console output.
- Reproduction steps.
- Recent code or asset changes.

### Step 2 - Hypotheses

Use `project-architect` and `unity-implementer` only if both roles are needed:

```text
Hypothesis 1: [cause]
Evidence needed: [what would confirm it]

Hypothesis 2: [cause]
Evidence needed: [what would confirm it]
```

### Step 3 - Debug Instrumentation

Add temporary debug logs only where they can prove or reject a hypothesis.

```csharp
Debug.Log($"[DEBUG] {nameof(MyMethod)}: value={value}, state={_state}");
```

Ask the user to reproduce the scenario and paste the relevant log.

### Step 4 - Evidence Gate

- Confirmed hypothesis -> apply the fix.
- Rejected hypothesis -> remove bad assumption and create a new hypothesis.
- Still unclear -> gather narrower evidence.

### Step 5 - Fix

Continue with the `/fix` pipeline:

```text
investigate -> fix -> regression test -> validate -> review -> optional commit
```

### Step 6 - Clean Up

Remove temporary debug logs before the final commit.

