# Unity Claude AI Workflow

A multi-agent AI workflow system with Claude Code integration for Unity 6 projects.

## Setup

Copy this `.claude/` folder to the root directory of your Unity project.
Then run `/setup-project` — it detects and configures the DI container, input system, and
optional features.

## Quick Start

```
/context-prime    → Introduce the project to Claude
/setup-project    → DI/Input/async detect + feature selection
/game-idea        → New project: generate GDD
/implement <task> → Existing project: start TDD pipeline
```

## Architecture Principles

- **DI required:** VContainer or Zenject (singletons forbidden)
- **Async:** UniTask (coroutines forbidden)
- **Input:** New Input System or Legacy (auto-detected)
- **Scene/Prefab:** Edit via MCP, direct editing forbidden
- **Module structure:** Interface → Service → Config → Installer → Events

## Review Modes

Edit `production/review-mode.txt`:
- `solo` — Coder → committer only (jam/prototype)
- `lean` — Full pipeline, default
- `full` — unity-developer always active

## Documentation

@.claude/docs/hooks-blocking.md
@.claude/docs/agents-index.md
@.claude/docs/skills-index.md
@.claude/docs/commands.md
@.claude/docs/auto-loaded-skills.md

## Project Configuration

Current settings: `.claude/project-config.json`
Hooks and permissions: `.claude/settings.json` (cannot be edited by Claude)
Session state: `.claude/state/` (in .gitignore)
