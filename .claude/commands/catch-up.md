# /catch-up

Generates a human-readable codebase guide.

## Usage

```
/catch-up
```

## Workflow

### Step 1 — Scan Codebase

With `project-architect`:
- List all Interfaces
- List all Services
- Extract the dependency graph

### Step 2 — Generate CATCH_UP.md

`docs/CATCH_UP.md`:

```markdown
# Codebase Guide — [Date]

## Systems

| System | Interface | Responsibility |
|---|---|---|
| Audio | IAudioService | Play, stop, volume |
| Player | IPlayerService | Movement, input, state |

## Dependency Graph
[Text diagram]

## DI Wiring
[What is registered in AppScope / GameScope]

## Key Patterns
[Critical patterns used in the project]
```

### Step 3 — Commit

```bash
git add docs/CATCH_UP.md
git commit -m "docs: update CATCH_UP.md codebase guide"
```
