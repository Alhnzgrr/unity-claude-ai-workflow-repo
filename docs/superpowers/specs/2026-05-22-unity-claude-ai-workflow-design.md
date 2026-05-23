# Unity Claude AI Workflow - Design Spec

**Date:** 2026-05-22  
**Status:** Approved

## 1. Project Goal

This repository provides a public, copyable `.claude/` template for Unity 6 projects. The template gives Claude Code a disciplined multi-agent workflow for game development through slash commands, specialist agents, architectural rules, guardrail hooks, reusable skills, and human approval checkpoints.

## 2. Distribution Strategy

The repository is distributed as a pure `.claude/` template. Users copy the `.claude/` directory into the root of a Unity project and run `/setup-project`.

Expected top-level structure:

```text
unity-claude-ai-workflow-repo/
├── .claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── project-config.json
│   ├── commands/
│   ├── agents/
│   ├── rules/
│   ├── skills/
│   ├── hooks/
│   ├── docs/
│   └── state/
├── docs/
├── production/
└── README.md
```

Core constraints:
- `.claude/settings.json` is protected from Claude edits.
- `.claude/state/` stores runtime session data and is ignored where appropriate.
- `.claude/project-config.json` is the source of truth for project feature flags.

## 3. Package Stack and Auto-Detection

The system does not force a single Unity stack. `/setup-project` detects the active stack from project files.

| Category | Supported options | Detection source |
|---|---|---|
| DI container | VContainer, Zenject, none | `Packages/manifest.json` |
| Async | UniTask | `Packages/manifest.json` |
| Input | New Input System, Legacy Input Manager | package/project settings |
| Optional | ECS, Addressables, XR | user selection + package validation |

Default configuration:

```json
{
  "di": "vcontainer",
  "async": "unitask",
  "input": "new",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general",
  "unity_version": "6000",
  "review_mode": "lean"
}
```

## 4. Command Set

The template defines 25 slash commands.

Design commands:
- `/game-idea`
- `/architect`
- `/plan-workflow`
- `/dry-run`

Implementation commands:
- `/setup-project`
- `/implement <task>`
- `/fix <bug>`
- `/fix-lite <bug>`
- `/fix-deep <bug>`
- `/orchestrate`
- `/continue`
- `/new-module`

Quality commands:
- `/qa`
- `/ralph`
- `/validate`
- `/review-code`
- `/performance-audit`

Documentation and learning commands:
- `/learn`
- `/catch-up`
- `/adr <decision>`
- `/smart-commit`

Session and context commands:
- `/context-prime`
- `/checkpoint`
- `/search <query>`
- `/discover`

## 5. Agent Roster

The system defines 22 specialist agents.

Core pipeline:
- `unity-coder`
- `coder`
- `unity-coder-lite`
- `tester`
- `unity-verifier`
- `reviewer`
- `unity-reviewer`
- `committer`

Specialists:
- `unity-fixer`
- `unity-fixer-lite`
- `unity-scout`
- `unity-critic`
- `silent-failure-hunter`
- `unity-developer`

Setup and configuration:
- `unity-setup`
- `unity-scene-builder`
- `unity-migrator`
- `package-analyzer`

Quality, architecture, and build:
- `unity-optimizer`
- `unity-linter`
- `unity-architect`
- `unity-build-runner`

## 6. Rules

The required rule set covers architecture, dependency injection, async, Unity lifecycle, input, performance, serialization, testing, event patterns, prefabs, scene hierarchy, and C# style.

Optional rules are loaded when the corresponding project feature is enabled:
- `ecs-dots.md`
- `addressables.md`

## 7. Hooks

Blocking hooks stop unsafe writes with exit code 2:
- Direct `.unity`, `.prefab`, and `.asset` edits
- Runtime `UnityEditor` usage without guards
- Unity API usage in pure C# framework code
- Legacy input API usage when New Input System is active
- Static singleton patterns
- `UnityEvent`
- Coroutines when UniTask is required
- Protected config edits
- Editing unread C# files in the current session

Warning hooks report risks but allow the write:
- LINQ in hot paths
- expensive hot path calls
- `async void`
- missing UniTask cancellation tokens
- Unity null-check pitfalls
- missing `FormerlySerializedAs` on serialized renames

## 8. Skills

Skills are organized into:
- `core/`: always-loaded decision and workflow guidance
- `systems/`: feature-specific Unity system guidance
- `third-party/`: package-specific guidance loaded from detection
- `learned/`: project-specific patterns created by `/learn`

## 9. Director Gates

Human approval gates are used at critical points:

| Gate | Trigger | Expected decision |
|---|---|---|
| `SCOPE_GATE` | Start of `/implement`, `/fix`, or `/orchestrate` | `go` or redirected scope |
| `ARCHITECTURE_GATE` | New module creation | approve module shape |
| `BREAKING_GATE` | 3+ files affected | approve wider scope |
| `QUALITY_GATE` | reviewer returns `CHANGES NEEDED` | `fix`, `skip`, or `stop` |
| `COMMIT_GATE` | verification complete | approve final staged commit |

## 10. Review Mode

`production/review-mode.txt` controls pipeline depth:

| Mode | Behavior |
|---|---|
| `solo` | coder -> committer |
| `lean` | standard pipeline, default |
| `full` | always includes `unity-developer` |

## 11. Core `/implement` Pipeline

```text
SCOPE_GATE
tester
unity-coder or coder
unity-verifier
reviewer or unity-reviewer
QUALITY_GATE when needed
silent-failure-hunter
COMMIT_GATE
committer
```

## 12. MCP Integration

Unity MCP support is optional. When MCP is available, setup, scene building, verification, and editor operations use Unity Editor tools. When MCP is unavailable, the system provides clear manual Unity Editor instructions.

## 13. Out of Scope

This version does not include mobile-specific skills, PC-specific skills, Codex/Cursor adapters, installer scripts, or complete CI/CD setup.
