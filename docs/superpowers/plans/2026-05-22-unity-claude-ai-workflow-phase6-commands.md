# Unity Claude AI Workflow - Phase 6: Commands

## Goal

Create 25 slash command workflow files under `.claude/commands/`.

## Command Files

Design phase:
- `game-idea.md`
- `architect.md`
- `plan-workflow.md`
- `dry-run.md`

Setup and scaffolding:
- `setup-project.md`
- `new-module.md`

Implementation:
- `implement.md`
- `fix.md`
- `fix-lite.md`
- `fix-deep.md`
- `orchestrate.md`
- `continue.md`

Quality:
- `qa.md`
- `ralph.md`
- `validate.md`
- `review-code.md`
- `performance-audit.md`

Documentation and learning:
- `learn.md`
- `catch-up.md`
- `adr.md`
- `smart-commit.md`

Session and context:
- `context-prime.md`
- `checkpoint.md`
- `search.md`
- `discover.md`

## Command Requirements

Each command file should define:
- Purpose
- Usage
- Preconditions
- Step-by-step workflow
- Director Gate behavior when relevant
- Expected output format
- Commit behavior when the command writes files

## Key Workflows

`/game-idea` converts a raw game idea into `docs/GDD.md`.

`/architect` converts `docs/GDD.md` into `docs/TDD.md` using `unity-architect` and `unity-critic`.

`/plan-workflow` converts `docs/TDD.md` into phased `docs/WORKFLOW.md`.

`/dry-run` previews the workflow execution plan without writing files.

`/setup-project` detects DI, async, input, and optional feature flags, then updates `.claude/project-config.json`.

`/new-module` scaffolds the standard module shape: interface, service, configuration, installer, events, and optional provider.

`/implement` runs the TDD pipeline: tester, coder, verifier, reviewer, silent-failure audit, and committer.

`/fix` runs the bug-fix pipeline: scout, fixer, regression test, verifier, reviewer, and committer.

`/fix-lite` handles obvious low-risk one-file fixes.

`/fix-deep` requires evidence before applying a fix.

`/orchestrate` executes `docs/WORKFLOW.md` phase by phase.

`/continue` resumes a previous orchestration from `.claude/state/session.json`.

`/qa` runs the quality pipeline.

`/ralph` runs a verify-fix loop for up to 10 iterations.

`/validate` checks phase exit criteria.

`/review-code` reviews selected files.

`/performance-audit` checks hot path and runtime performance risks.

`/learn` captures project-specific patterns into `.claude/skills/learned/`.

`/catch-up` creates a human-readable codebase guide.

`/adr` creates an Architecture Decision Record.

`/smart-commit` groups dirty working tree changes into semantic commits.

`/context-prime` loads project context at session start.

`/checkpoint` writes a session summary into `.claude/state/checkpoint.md`.

`/search` routes codebase research through `unity-scout`.

`/discover` scans packages and scaffolds third-party skill drafts.

## Verification

- All 25 command files exist.
- Each command file documents purpose, usage, workflow, and output.
- Commands that write files document expected commit behavior.
- Commands that can change scope document the relevant Director Gate.
