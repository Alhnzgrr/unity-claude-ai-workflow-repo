# /discover

Scans Packages/manifest.json and generates skill drafts for installed packages.

## Usage

```
/discover [--dry-run | --write]
```

- `--dry-run` → Shows what would be generated, does not write files
- `--write` → Writes skill files
- No argument → Behaves like `--dry-run`, asks for confirmation

## Workflow

### Step 1 — Read manifest.json

Read `Packages/manifest.json`. List all packages.

### Step 2 — Spawn package-analyzer

`package-analyzer`:
- Identify known packages (VContainer, UniTask, DOTween...)
- Detect those that use singletons
- Flag those that need an adapter

### Step 3 — Generate Skill Drafts

For each unknown package, a `skills/third-party/[package-name]/SKILL.md` draft:

```markdown
---
name: [package-name]
description: [package purpose]
discovered: true
---

# [Package Name]

## Installation

[Package ID from manifest.json]

## Basic Usage

[TODO: Fill in basic patterns]

## DI Compatibility

[Singleton? Does it need an adapter?]
```

### Step 4 — User Confirmation

```
Packages found: [N]
New skill drafts: [M]
Adapter suggestions: [K packages]

Write them? (yes/no)
```

### Step 5 — Commit (on --write or confirmation)

```bash
git add .claude/skills/third-party/
git commit -m "feat: discover and scaffold [N] package skills"
```
