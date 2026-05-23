# Command Reference

## Design Phase
| Command | Description |
|---|---|
| `/game-idea` | Converts raw idea into GDD |
| `/architect` | GDD → TDD, adversarial review with unity-critic |
| `/plan-workflow` | Splits TDD into phases → WORKFLOW.md |
| `/dry-run` | Previews orchestration plan |

## Implementation Phase
| Command | Description |
|---|---|
| `/setup-project` | Detect + selection wizard, creates folder structure |
| `/implement <task>` | TDD pipeline: test→coder→verifier→reviewer→committer |
| `/fix <bug>` | Bug fix pipeline |
| `/fix-lite <bug>` | Fast path: NullRef, typo, single line |
| `/fix-deep <bug>` | Evidence-first: no fix without proven root cause |
| `/orchestrate` | Executes WORKFLOW.md phase by phase |
| `/continue` | Resumes an interrupted /orchestrate |
| `/new-module` | 5-file scaffold (Interface, Service, Config, Installer, Events) |

## Quality Phase
| Command | Description |
|---|---|
| `/qa` | Full quality pipeline: ralph→silent-failure-hunt→validate |
| `/ralph` | Verify-fix loop until green (max 10 iterations) |
| `/validate` | Exit criteria check for the current phase |
| `/review-code` | Deep review of specific files |
| `/performance-audit` | Hot path allocation & draw call audit |

## Documentation & Learning
| Command | Description |
|---|---|
| `/learn` | Saves patterns under skills/learned/ |
| `/catch-up` | Human-readable codebase guide → docs/CATCH_UP.md |
| `/adr <decision>` | Creates an Architecture Decision Record |
| `/smart-commit` | Splits dirty tree into semantic commits |

## Session & Context
| Command | Description |
|---|---|
| `/context-prime` | Brings Claude into project context at session start |
| `/checkpoint` | Saves conversation summary to state |
| `/search <query>` | Codebase research → action router |
| `/discover` | Scans manifest.json and generates package skills |
