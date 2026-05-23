---
name: context-management
description: Guide for review mode, context economy, compaction, and checkpoint usage.
---

# Context Management

## Review Mode

`production/review-mode.txt` controls pipeline depth:

| Mode | Validation | Review | Usage |
|---|---|---|---|
| `solo` | Basic | Skip unless risky | Jam, prototype, quick experiment |
| `lean` | Standard | Standard `code-reviewer` pass | Normal development |
| `full` | Standard | Stricter `code-reviewer` depth | Team work, learning, critical feature |

Reading review mode:

```bash
cat production/review-mode.txt
```

## Checkpoint Usage

Use checkpoints before long pauses or context-heavy work:

```text
/checkpoint
```

Then resume with:

```text
/context-prime
```

## Context Economy

- Avoid reading unnecessary files in long sessions.
- Do not re-read files already read in the same session unless they changed.
- Load only the skills relevant to the current task.
- Use `project-architect` for discovery when research would otherwise crowd the main session.
- Use compact summaries before switching from design to implementation.

## Session State Files

```text
.claude/state/
  session.json      active branch, phase, changed files
  checkpoint.md     created by /checkpoint
  gate-cleared      created after Director Gate approval, deleted when pipeline ends
  read-files.log    list of files read for gateguard
```

