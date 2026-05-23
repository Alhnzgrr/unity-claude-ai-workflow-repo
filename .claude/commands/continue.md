# /continue

Resumes an interrupted /orchestrate from where it left off.

## Usage

```
/continue
```

## Workflow

### Step 1 — Read State

Read `.claude/state/session.json`:
- Which phase were we on?
- Which task was completed?
- Which files were changed?

### Step 2 — Read Checkpoint (if present)

Read `.claude/state/checkpoint.md` — gather context.

### Step 3 — Resume

```
Last state: Phase [N], Task [M] completed.
Resuming from [Task M+1]...
```

Enter the Phase Loop from Step 1 of `/orchestrate` at the remaining task.

## Session State Format

`.claude/state/session.json`:
```json
{
  "current_phase": 2,
  "current_task": "Task 2.3",
  "completed_tasks": ["Task 1.1", "Task 1.2", "Task 2.1", "Task 2.2"],
  "modified_files": ["Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs"]
}
```
