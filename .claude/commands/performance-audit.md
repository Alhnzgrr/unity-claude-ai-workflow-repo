# /performance-audit

Hot path allocation and draw call audit.

## Usage

```
/performance-audit [optional: folder or file]
```

## Workflow

### Step 1 — Scan Scope

If specified, that file/folder; otherwise the entire `Concretes/` folder.

### Step 2 — unity-optimizer

Spawn `unity-optimizer`:
- Scan Update/FixedUpdate methods
- Find allocation patterns
- LINQ usage
- Is GetComponent/Camera.main/Find* in hot path?

### Step 3 — unity-developer (in full mode)

review-mode == `full` → `unity-developer` provides additional perspective.

### Step 4 — Report

```
## Performance Audit Report

### Critical (fix immediately)
- [file:line]: [issue] → [suggestion]

### Watch
- [file:line]: [issue]

### Clean
- [N] files scanned, no issues
```
