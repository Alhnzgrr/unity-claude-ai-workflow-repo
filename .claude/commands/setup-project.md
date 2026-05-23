# /setup-project

Detects, configures, and creates the folder structure for the project.

## Usage

```
/setup-project
```

## Workflow

### Step 1 — Detect manifest.json

Read `Packages/manifest.json`:

```bash
# VContainer or Zenject?
DI="none"
grep -q "jp.hadashikick.vcontainer" Packages/manifest.json && DI="vcontainer"
grep -q "com.svermeulen.extenject" Packages/manifest.json && DI="zenject"

# UniTask present?
grep -q "com.cysharp.unitask" Packages/manifest.json && ASYNC="unitask"

# DOTween present?
grep -q "com.demigiant.dotween" Packages/manifest.json && HAS_DOTWEEN=true
```

### Step 2 — Detect Input System

Check `ProjectSettings/ProjectVersion.txt` and Input Manager:
- Is the New Input System package present? → `"input": "new"`
- Otherwise → `"input": "legacy"`

### Step 3 — Optional Feature Selection

Ask the user (one at a time):
1. Will you use ECS/DOTS? (ecs: true/false)
2. Will you use Addressables? (addressables: true/false)
3. Will you do XR/VR development? (xr: true/false)

### Step 4 — Update project-config.json

Update `.claude/project-config.json`:

```json
{
  "di": "[detected]",
  "async": "unitask",
  "input": "[detected]",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general",
  "unity_version": "6000"
}
```

### Step 5 — Create Folder Structure

```
Assets/
├── _Framework/
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/
        │   └── Concretes/
        ├── Tests/
        │   ├── [Project]EditModeTest/
        │   └── [Project]PlayModeTest/
        └── Editors/
```

### Step 6 — Show Summary

```
✅ Setup complete

DI Container: vcontainer
Async: unitask
Input: new input system
ECS: false
Addressables: false
XR: false

Folder structure created: Assets/_Framework/ + Assets/_GameFolders/

Next step: /game-idea or /implement
```
