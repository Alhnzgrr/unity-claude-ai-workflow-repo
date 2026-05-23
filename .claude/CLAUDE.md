# Unity Claude AI Workflow

A compact multi-agent workflow system with Claude Code integration for Unity 6 projects.

## Setup

Copy this `.claude/` folder to the root directory of your Unity project.
Then run `/setup-project`; it detects and configures the DI container, input system, and optional features.

## Quick Start

```text
/context-prime    -> Introduce the project to Claude
/setup-project    -> DI/Input/async detection and feature selection
/game-idea        -> New project: generate GDD
/implement <task> -> Existing project: run the implementation pipeline
```

## Architecture Principles

- **DI required:** VContainer or Zenject; singletons are forbidden.
- **Async:** UniTask; coroutines are forbidden by default.
- **Input:** New Input System or Legacy is detected by project config.
- **Scene/Prefab:** Edit through MCP or manual Unity Editor steps; direct text editing is forbidden.
- **Module structure:** Interface -> Service -> Config -> Installer -> Events.

## Review Modes

Edit `production/review-mode.txt`:

- `solo` -> implementation and validation only for fast prototypes.
- `lean` -> implementation, validation, and review; default.
- `full` -> lean mode plus stricter review depth for risky changes.

## Active Agents

- `project-architect`
- `unity-implementer`
- `code-reviewer`
- `test-validator`
- `performance-auditor`
- `docs-maintainer`

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
