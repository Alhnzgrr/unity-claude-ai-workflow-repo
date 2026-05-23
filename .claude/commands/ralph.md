# /ralph

Verify-fix loop until green. Max 10 iterations.

## Usage

```
/ralph
```

## Workflow

```
iteration = 0

LOOP:
  iteration += 1
  unity-verifier → compile + test
  
  PASSED → "Green! Passed in [iteration] iteration(s)." → STOP
  
  FAILED:
    iteration >= 10 → "STUCK: Still red after 10 iterations." → STOP
    unity-coder → fix the error
    go back to LOOP
```

## Stuck Exit

If not passing after 10 iterations:
```
❌ STUCK after 10 iterations
Last error: [error message]
Suggestion: run /fix-deep for root cause analysis
```
