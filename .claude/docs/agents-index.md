# Agent Roster

The workflow intentionally keeps the agent layer small. Agents own broad decision roles; skills carry package, system, and pattern details.

## Active Agents

| Agent | Role | Model |
|---|---|---|
| `project-architect` | System design, codebase discovery, dependency boundaries, package analysis, migration planning | Heavy |
| `unity-implementer` | Unity and pure C# implementation, bug fixes, migrations, scene/prefab setup through MCP | Normal |
| `code-reviewer` | Code review, Unity lifecycle safety, static checks, silent failure audit, maintainability review | Normal |
| `test-validator` | Test writing, EditMode/PlayMode choice, compile/test/build validation | Normal |
| `performance-auditor` | Runtime performance, memory, mobile/VR, rendering, hot-path allocation audit | Normal |
| `docs-maintainer` | README, rules, skills, command docs, learned patterns, ADRs, and indexes | Light |

## Former Role Mapping

| Former role | Now handled by |
|---|---|
| `unity-architect`, `unity-critic`, `unity-scout`, `package-analyzer` | `project-architect` |
| `unity-coder`, `coder`, `unity-coder-lite`, `unity-fixer`, `unity-fixer-lite`, `unity-migrator`, `unity-setup`, `unity-scene-builder` | `unity-implementer` |
| `reviewer`, `unity-reviewer`, `unity-linter`, `silent-failure-hunter`, `unity-developer` | `code-reviewer` |
| `tester`, `unity-verifier`, `unity-build-runner` | `test-validator` |
| `unity-optimizer` | `performance-auditor` |
| `committer` | Main agent after commit approval |

## Routing Rule

Prefer one agent per step. Add another agent only when it has a different decision responsibility, not merely because the topic has a named skill.
