# Setup Guide

## 1. Copy the `.claude/` Folder

**Mac/Linux:**
```bash
cp -r unity-claude-ai-workflow-repo/.claude/ YourUnityProject/.claude/
```

**Windows:**
```powershell
Copy-Item -Recurse unity-claude-ai-workflow-repo\.claude\ YourUnityProject\.claude\
```

## 2. Make Sure Git Bash Is Installed

The hooks are Bash scripts. Git Bash is required on Windows.
Download: https://git-scm.com/download/win

## 3. Grant Hook Permissions (Linux/Mac)

```bash
chmod +x YourUnityProject/.claude/hooks/*.sh
```

## 4. Open Claude Code

Start Claude Code in the root directory of your Unity project.

## 5. Run the Setup Wizard

```
/setup-project
```

This command:
- Scans `manifest.json` and detects VContainer/Zenject and UniTask
- Detects the input system
- Asks about optional ECS, Addressables, and XR support
- Fills `.claude/project-config.json`
- Creates the recommended folder structure

## Verification

```
/context-prime
```

If Claude can describe the project correctly, setup is complete.

## Troubleshooting

**Hooks do not run:** Check whether `jq` is installed with `jq --version`.
- Windows: `winget install jqlang.jq`
- Mac: `brew install jq`

**settings.json permission error:** This file cannot be edited by Claude by design.
