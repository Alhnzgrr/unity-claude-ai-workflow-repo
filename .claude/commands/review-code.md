# /review-code

Performs a deep review of specific files.

## Usage

```
/review-code <file path or glob pattern>
```

Examples:
```
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/
```

## Workflow

### Step 1 — Read Files

Read the specified files with the Read tool (required to bypass gateguard).

### Step 2 — unity-reviewer

Spawn `unity-reviewer`. With the full review checklist.

### Step 3 — Show Report

Display the reviewer output:
- Must Fix (blocker)
- Should Improve (suggestion)
- Optional (nice-to-have)
- Unity Notes (Unity-specific)

### Step 4 — User Decision

If Must Fix items exist: "Would you like me to fix them? (yes/no)"
