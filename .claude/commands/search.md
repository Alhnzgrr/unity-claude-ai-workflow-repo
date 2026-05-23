# /search

Codebase research and action router.

## Usage

```
/search <query>
```

Examples:
```
/search Where is IAudioService implemented?
/search Is there a singleton pattern?
/search Who uses PlayerService?
```

## Workflow

### Step 1 — project-architect

Spawn `project-architect`:
- Find relevant code using Grep and Glob
- Build a dependency map
- Report findings

### Step 2 — code-reviewer (if analysis is needed)

If a finding requires review (architecture violation, etc.) → add `code-reviewer`.

### Step 3 — Action Router

Suggestion based on result:
```
## Search Result

[Findings]

## Suggested Action
- Issue found → fix with /fix
- Refactor needed → new approach with /implement
- Info only → information provided, no action needed
```
