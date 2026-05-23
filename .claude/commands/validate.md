# /validate

Exit criteria check for the completed phase.

## Usage

```
/validate
```

## Checklist

- [ ] Compile: no errors
- [ ] EditMode tests: all passing
- [ ] PlayMode tests (if any): all passing
- [ ] Console: no errors or exceptions (warnings acceptable)
- [ ] Serialization risk: FormerlySerializedAs checked
- [ ] Silent failures: clean
- [ ] Architecture rules: no violations (run unity-linter)

## Output

```
## Validation Report

Compile: ✅ OK
EditMode Tests: ✅ [N] passed
PlayMode Tests: ✅ [N] passed
Console Errors: ✅ Clean
Serialization: ✅ No risk
Silent Failures: ✅ Clean

Result: PASS / PARTIAL / FAIL
```

PARTIAL or FAIL → specify which item is blocking.
