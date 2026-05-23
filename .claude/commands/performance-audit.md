# /performance-audit

Audits hot paths, allocations, memory, rendering cost, and platform performance risk.

## Usage

```text
/performance-audit [optional: folder or file]
```

## Workflow

### Step 1 - Scope

If a file or folder is provided, audit that scope. Otherwise audit likely runtime code under the project gameplay folders.

### Step 2 - performance-auditor

Spawn `performance-auditor`:

- Scan Update, FixedUpdate, LateUpdate, async loops, and event-heavy paths.
- Check allocations, LINQ, string formatting, repeated lookups, and object creation.
- Check rendering, UI, physics, Addressables, pooling, mobile, and VR risks when relevant.

### Step 3 - code-reviewer

In `full` review mode, run `code-reviewer` for a second correctness and maintainability pass.

### Step 4 - Report

```text
## Performance Audit Report

### Critical
- [file:line]: [issue] -> [suggestion]

### Watch
- [file:line]: [issue]

### Clean
- [N] files scanned, no issues
```

