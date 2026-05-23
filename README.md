# Unity Claude AI Workflow

A copyable `.claude/` workflow template for Unity 6 projects that use Claude Code for AI-assisted game development.

This repository is not a Unity runtime framework. It is an AI workflow layer: commands, agents, rules, hooks, and skills that guide Claude Code toward safer, more repeatable Unity development.

## What This Provides

- **25 slash commands** for setup, planning, implementation, bug fixing, QA, reviews, documentation, and session management.
- **6 broad agents** for architecture, implementation, review, validation, performance, and documentation work.
- **14 rule files** covering architecture, dependency injection, async, Unity lifecycle, input, performance, serialization, testing, events, prefabs, scene hierarchy, C# style, ECS, and Addressables.
- **15 guardrail hooks** that block or warn about risky AI edits before they become project damage.
- **25 skill documents** for Unity architecture, Unity core safety, systems, and third-party packages such as UniTask, VContainer, Zenject, DOTween, Addressables, UI Toolkit, and VR.
- **Director Gates** for human approval at critical moments.
- **Hook test harness** to validate the guardrails with sample Claude Code JSON inputs.

## Who This Is For

This template is designed for Unity developers who want Claude Code to work inside a disciplined project workflow instead of producing ad-hoc code.

It fits best when your project uses or plans to use:

- Unity 6
- Claude Code
- UniTask
- VContainer or Zenject
- New Input System
- structured scenes, prefabs, and ScriptableObject configs
- testable gameplay systems with thin MonoBehaviours

It can still be adapted to other Unity projects, but some rules may need to be relaxed.

## Repository Layout

```text
.claude/
  CLAUDE.md                  Main Claude Code entry point
  settings.json              Hook and permission configuration
  project-config.json        Project feature flags
  agents/                    Compact agent role definitions
  commands/                  Slash command workflows
  docs/                      Internal command/agent/skill indexes
  hooks/                     Guardrail scripts
  rules/                     Architecture and Unity rules
  skills/                    Reusable technical guidance
  state/                     Runtime session state placeholder

docs/
  SETUP.md                   Setup guide
  QUICKSTART.md              Common workflow examples
  superpowers/               Design spec and phase plans

production/
  review-mode.txt            solo, lean, or full

tests/hooks/
  cases.json                 Hook fixture cases
  run-hooks.ps1              Hook test runner
```

## Requirements

- Unity 6 (6000.x)
- Claude Code CLI
- Git Bash for running hook scripts on Windows
- `jq` for JSON parsing in hooks
- UniTask in `Packages/manifest.json`
- VContainer or Zenject

Install `jq` on Windows:

```powershell
winget install -e --id jqlang.jq
```

## Setup

1. Clone this repository.
2. Copy the `.claude/` folder into the root of your Unity project.
3. Open Claude Code in the Unity project directory.
4. Run:

```text
/setup-project
```

The setup command is intended to detect or configure:

- DI container: VContainer, Zenject, or none
- async library: UniTask
- input mode: New Input System or Legacy
- optional ECS, Addressables, and XR flags
- recommended Unity project folder structure

For more detail, see [docs/SETUP.md](docs/SETUP.md).

## Quick Start

Prime Claude with project context:

```text
/context-prime
```

Start a new game from idea to implementation plan:

```text
/game-idea
/architect
/plan-workflow
/dry-run
/orchestrate
```

Implement a feature in an existing project:

```text
/implement "Implement AudioService"
```

Fix bugs:

```text
/fix "PlayerController throws a NullReferenceException"
/fix-lite "typo: PlayerControler -> PlayerController"
/fix-deep "FixedUpdate occasionally skips a frame and the root cause is unclear"
```

Run quality checks:

```text
/qa
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/
/performance-audit
```

For more examples, see [docs/QUICKSTART.md](docs/QUICKSTART.md).

## Review Modes

The file `production/review-mode.txt` controls how strict the workflow is.

| Mode | Behavior | Use case |
|---|---|---|
| `solo` | implementation and validation only | game jams, prototypes, fast experiments |
| `lean` | tests, implementation, verification, review | normal development |
| `full` | lean mode plus stricter review depth | teams, learning, critical systems |

The default is `lean`.

## Commands

Commands live in `.claude/commands/`.

Design:

- `/game-idea`
- `/architect`
- `/plan-workflow`
- `/dry-run`

Implementation:

- `/setup-project`
- `/implement`
- `/fix`
- `/fix-lite`
- `/fix-deep`
- `/orchestrate`
- `/continue`
- `/new-module`

Quality:

- `/qa`
- `/ralph`
- `/validate`
- `/review-code`
- `/performance-audit`

Documentation and learning:

- `/learn`
- `/catch-up`
- `/adr`
- `/smart-commit`

Session and context:

- `/context-prime`
- `/checkpoint`
- `/search`
- `/discover`

## Agents

Agents live in `.claude/agents/`.

The active agents are:

- `project-architect`: system design, discovery, dependency boundaries, package analysis, and migration planning.
- `unity-implementer`: Unity and pure C# implementation, bug fixes, migrations, and Unity MCP setup work.
- `code-reviewer`: code review, Unity lifecycle safety, static checks, silent failure audit, and maintainability review.
- `test-validator`: test writing, EditMode/PlayMode decisions, compile checks, hook checks, and build validation.
- `performance-auditor`: runtime performance, memory, mobile/VR, rendering, and hot-path allocation audit.
- `docs-maintainer`: README, rules, skills, command docs, learned patterns, ADRs, and indexes.

Agents own broad decision responsibilities. Package-specific and system-specific knowledge belongs in `.claude/skills/`, so the workflow avoids spawning a separate agent for every Unity package or subsystem.

## Rules

Rules live in `.claude/rules/`.

Important principles:

- Use dependency injection instead of singleton or service locator patterns.
- Use UniTask instead of coroutines for async work.
- Keep Unity input in view/adapter layers.
- Keep MonoBehaviours thin.
- Keep core game logic testable without a scene where possible.
- Avoid hot-path allocations.
- Protect serialized data with `FormerlySerializedAs` when fields are renamed.
- Do not directly edit `.unity`, `.prefab`, or `.asset` files through text edits.

Some rules are intentionally strict. Treat them as a default safety profile. If a project needs exceptions, document them explicitly.

## Skills

Skills live in `.claude/skills/`.

Skill categories:

- `core/`: model routing, Unity instincts, MCP patterns, context management
- `unity-architecture/`: clean architecture, view/environment separation, simulation loops
- `unity-core/`: serialization safety, input system, pooling, editor/runtime separation, mobile development
- `systems/`: audio, physics, animation, UI Toolkit, URP, Cinemachine, Shader Graph, Addressables, VR
- `third-party/`: VContainer, Zenject, UniTask, DOTween, TextMeshPro
- `learned/`: project-specific patterns created by `/learn`

Skills are the practical guidance layer. They explain not only what to do, but when to use a pattern, what mistakes to avoid, and how reviewers should evaluate the work.

## Hooks

Hooks live in `.claude/hooks/`.

Blocking hooks return exit code `2` and stop unsafe edits. Warning hooks return exit code `0` and print diagnostics.

Blocking examples:

- block direct scene, prefab, and asset edits
- block unguarded `UnityEditor` usage in runtime code
- block Unity API usage in `_Framework/`
- block legacy input APIs when New Input System is active
- block singleton patterns
- block `UnityEvent`
- block coroutines when UniTask is required
- protect config files

Warning examples:

- LINQ in hot paths
- `GetComponent`, `Camera.main`, or `Find*` in hot paths
- unsafe `async void`
- missing `CancellationToken` in UniTask methods
- Unity null-check pitfalls
- serialized field rename without `FormerlySerializedAs`

## Testing Hooks

The hook test harness validates hook behavior using representative Claude Code tool inputs.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\hooks\run-hooks.ps1
```

Expected output:

```text
All 22 hook tests passed.
```

The runner checks:

- expected exit code
- expected warning or block message
- safe cases that should pass

The runner requires Git Bash and `jq`. It attempts to find both from common Windows installation paths.

## Unity MCP

The workflow is designed to work better when Unity MCP is available.

When MCP is available, scene, prefab, inspector, compile, test runner, and console operations can be routed through Unity Editor tools.

When MCP is not available, the workflow should fall back to explicit manual Unity Editor instructions.

Direct text edits to `.unity`, `.prefab`, and `.asset` files are blocked by default.

## Recommended Development Flow

For a new project:

```text
/context-prime
/setup-project
/game-idea
/architect
/plan-workflow
/dry-run
/orchestrate
/qa
```

For an existing feature:

```text
/context-prime
/implement "Feature description"
/qa
```

For a hard bug:

```text
/context-prime
/fix-deep "Bug description and logs"
/qa
```

## Current Limitations

- This template defines workflows and guardrails; it is not a deterministic orchestrator.
- Slash commands still rely on Claude Code following the command instructions.
- Hook checks are regex-based and may need project-specific tuning.
- Some rules are intentionally strict and may need documented exceptions.
- Unity scene and prefab automation is strongest when MCP is connected.
- The repository does not include a full sample Unity project yet.

## Suggested Next Improvements

- Add a sample Unity module flow.
- Add more hook test cases for edge cases and false positives.
- Add rule exception documentation.
- Add documentation quality hooks for stale agent names, missing frontmatter, and malformed skill structure.
- Add a real Unity project smoke test for `/setup-project`, `/implement`, and `/qa`.

## License

MIT
