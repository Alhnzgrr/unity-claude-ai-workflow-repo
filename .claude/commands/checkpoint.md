# /checkpoint

Saves a conversation summary to state. Guards against context loss in long sessions.

## Usage

```
/checkpoint
```

## Workflow

### Step 1 — Create Summary

Summarize what was done in this session:
- Which tasks were completed
- Which files were created/modified
- Which decisions were made
- Where we left off

### Step 2 — Save

`.claude/state/checkpoint.md`:

```markdown
# Checkpoint — [Date Time]

## Completed This Session
- [completed tasks]

## Modified Files
- [file list]

## Decisions Made
- [architectural decisions, trade-offs]

## Resume Point
[Where the next session should pick up]
```

### Step 3 — Confirm

```
✅ Checkpoint saved: .claude/state/checkpoint.md
Can be loaded in a new session with /context-prime.
```
