---
name: context-management
description: Guide for review mode, context compaction, and checkpoint usage.
---

# Context Management

## Review Mode

`production/review-mode.txt` is read to determine pipeline depth:

| Mode | Test | Review | unity-developer | Usage |
|---|---|---|---|---|
| `solo` | ❌ | ❌ | ❌ | Jam, prototype, quick experiment |
| `lean` | ✅ | ✅ | Optional | Normal development (default) |
| `full` | ✅ | ✅ | Always ✅ | Team, learning, critical feature |

Reading review mode:
```bash
cat production/review-mode.txt
```

## Checkpoint Usage

To continue without losing context in long sessions:

```
/checkpoint
```

→ Creates `.claude/state/checkpoint.md`. In a new session:

```
/context-prime
```

→ Loads the checkpoint, introduces the project.

## Context Economy

- Avoid reading unnecessary files in long sessions
- Do not re-read files already read in a session
- Load skills only for the relevant task
- `unity-scout` handles research, preserving the main agent's context

## Session State Files

```
.claude/state/
├── session.json      ← active branch, phase, changed files
├── checkpoint.md     ← created by /checkpoint
├── gate-cleared      ← created after Director Gate approval, deleted when pipeline ends
└── read-files.log    ← list of files read for gateguard
```
