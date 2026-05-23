# /smart-commit

Splits a dirty working tree into logical semantic commit groups.

## Usage

```
/smart-commit
```

## Workflow

### Step 1 — Scan Changes

```bash
git diff --name-only
git status --short
```

### Step 2 — Group

Split changes into logical groups:
- Files belonging to the same module → single commit
- Test files → separate commit
- Documentation → separate commit
- Config changes → separate commit

### Step 3 — Show to User

```
Suggested commit groups:

Group 1: feat(audio) — AudioService, AudioInstaller, IAudioService
Group 2: test(audio) — AudioServiceTests
Group 3: docs — GDD.md update

Do you approve? (go / edit groups)
```

### Step 4 — Create Commits

A separate commit for each group:
```bash
git add [group files]
git commit -m "[type]([scope]): [description]"
```
