# Command Reference

## Design Phase

| Command | Description |
|---|---|
| `/game-idea` | Converts a raw idea into a GDD |
| `/architect` | Converts GDD into TDD with `project-architect` |
| `/plan-workflow` | Splits TDD into phases and creates `WORKFLOW.md` |
| `/dry-run` | Previews the orchestration plan |

## Implementation Phase

| Command | Description |
|---|---|
| `/setup-project` | Detects project settings and creates recommended folder structure |
| `/implement <task>` | Runs test -> implement -> validate -> review |
| `/fix <bug>` | Runs investigate -> fix -> regression test -> validate -> review |
| `/fix-lite <bug>` | Fast path for obvious low-risk bugs |
| `/fix-deep <bug>` | Evidence-first debugging when root cause is unclear |
| `/orchestrate` | Executes `WORKFLOW.md` phase by phase |
| `/continue` | Resumes an interrupted `/orchestrate` |
| `/new-module` | Creates a module scaffold |

## Quality Phase

| Command | Description |
|---|---|
| `/qa` | Runs review and validation checks |
| `/ralph` | Verify-fix loop until green, with a maximum iteration limit |
| `/validate` | Exit criteria check for the current phase |
| `/review-code` | Focused review of specific files |
| `/performance-audit` | Hot path, memory, rendering, and draw-call audit |

## Documentation & Learning

| Command | Description |
|---|---|
| `/learn` | Saves reusable patterns under `skills/learned/` |
| `/catch-up` | Creates a human-readable codebase guide |
| `/adr <decision>` | Creates an Architecture Decision Record |
| `/smart-commit` | Splits dirty tree into semantic commits |

## Session & Context

| Command | Description |
|---|---|
| `/context-prime` | Brings Claude into project context at session start |
| `/checkpoint` | Saves conversation summary to state |
| `/search <query>` | Performs codebase research and routes next action |
| `/discover` | Scans packages and suggests relevant skills |

