# /qa

Runs the quality pipeline for the current change or phase.

## Usage

```text
/qa
```

## Workflow

### Step 1 - /ralph

Run the verify-fix loop with `test-validator` and `unity-implementer`. Stop when green or when the iteration limit is reached.

### Step 2 - code-reviewer

Spawn `code-reviewer`:

- Check silent failures.
- Check async, event, lifecycle, serialization, and test coverage risks.
- Report blockers first.

### Step 3 - /validate

Run phase exit criteria.

## Output

```text
QA PASSED
Ralph: [N] iterations, green
Review: passed
Validation: passed

QA FAILED
[Where it got stuck and why]
```

