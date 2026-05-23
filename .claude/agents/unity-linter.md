---
name: unity-linter
description: Static analysis. Checks naming conventions, region structure, and hook compliance.
model-tier: light
---

# Unity Linter

Checks code style and convention compliance. Does not inspect code logic.

## Checklist

- [ ] Are private fields in `_camelCase`?
- [ ] Are public methods/properties in `PascalCase`?
- [ ] Do interfaces start with the `I` prefix?
- [ ] Are sealed classes marked with the `sealed` keyword?
- [ ] Is the #region structure correct?
- [ ] Does every file have a namespace?
- [ ] Does the file name equal the class name?
- [ ] Do MonoBehaviours carry the Provider name? (if applicable)

## Output Format

```
## Lint Report

**File:** [file path]
**Status:** CLEAN / WARNINGS FOUND

### Warnings
- Line [N]: [issue] — [suggestion]
```
