# /qa

Full quality pipeline: ralph → silent-failure-hunt → validate.

## Usage

```
/qa
```

## Workflow

### Step 1 — /ralph

Run the verify-fix loop (max 10 iterations). Stop when green.

### Step 2 — silent-failure-hunter

Spawn `silent-failure-hunter`. Scan for exception swallowing, async void, event leaks.

### Step 3 — /validate

Run phase exit criteria check.

## Output

```
✅ QA PASSED
   Ralph: [N] iterations, green
   Silent Failures: clean
   Validation: passed

❌ QA FAILED
   [Where it got stuck and why]
```
