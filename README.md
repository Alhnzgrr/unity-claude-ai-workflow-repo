# Unity Claude AI Workflow

A multi-agent AI workflow system with Claude Code integration for Unity 6 projects.

## Features

- **25 slash commands**: `/implement`, `/fix`, `/orchestrate`, `/qa`, and more
- **22 specialist agents**: coder, tester, reviewer, fixer, scout, critic, and more
- **12 architecture rules**: DI, async, lifecycle, performance, serialization, and more
- **15 guardrail hooks**: singleton, coroutine, UnityEvent, and direct scene edit protection
- **Skills library**: VContainer, Zenject, UniTask, VR, URP, and more
- **Director Gates**: human approval checkpoints at critical moments
- **Auto-detection**: DI container and input system detection from `manifest.json`

## Setup

1. Clone this repository.
2. Copy the `.claude/` folder into the root of your Unity project.
3. Open Claude Code in the Unity project directory.
4. Run the `/setup-project` command.

## Requirements

- Unity 6 (6000.x)
- Claude Code CLI
- Git Bash for hooks
- UniTask listed in `manifest.json`
- VContainer or Zenject

## Quick Start

```
/context-prime     Introduce the project to Claude
/game-idea         New game idea -> GDD
/architect         GDD -> TDD (technical design)
/plan-workflow     TDD -> WORKFLOW.md (phases + tasks)
/orchestrate       Execute WORKFLOW.md
```

## License

MIT
