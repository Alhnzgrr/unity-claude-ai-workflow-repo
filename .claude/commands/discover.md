# /discover

Scans `Packages/manifest.json` and suggests skills for installed packages.

## Usage

```text
/discover [--dry-run | --write]
```

- `--dry-run`: show what would be generated without writing files.
- `--write`: write approved skill drafts.
- No argument: behave like `--dry-run` and ask for confirmation.

## Workflow

### Step 1 - Read manifest.json

Read `Packages/manifest.json` and list installed packages.

### Step 2 - project-architect

Spawn `project-architect`:

- Identify known packages such as VContainer, Zenject, UniTask, DOTween, Addressables, Cinemachine, and TextMeshPro.
- Flag packages that imply singleton, async, rendering, input, or asset-loading rules.
- Suggest whether the package needs a new skill or can use an existing one.

### Step 3 - Generate Skill Drafts

For each approved unknown package, create a draft under `.claude/skills/third-party/[package-name]/SKILL.md`.

### Step 4 - Confirmation

```text
Packages found: [N]
New skill drafts: [M]
Adapter suggestions: [K packages]

Write them? (yes/no)
```

### Step 5 - Commit

Ask for approval before committing generated skills.

