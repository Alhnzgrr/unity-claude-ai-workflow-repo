# Unity Claude AI Workflow - Phase 1: Foundation

## Goal

Create the repository skeleton, primary configuration files, and the `.claude/CLAUDE.md` entry point.

## Deliverables

- `.claude/CLAUDE.md`
- `.claude/settings.json`
- `.claude/project-config.json`
- `.claude/docs/agents-index.md`
- `.claude/docs/skills-index.md`
- `.claude/docs/hooks-blocking.md`
- `.claude/docs/commands.md`
- `.claude/docs/auto-loaded-skills.md`
- `.claude/state/.gitkeep`
- `production/review-mode.txt`
- `.gitignore`
- `README.md`
- `docs/SETUP.md`
- `docs/QUICKSTART.md`

## Tasks

1. Create the `.claude/` folder structure for commands, agents, rules, skills, hooks, docs, and state.
2. Add `.gitignore` rules for session state, generated runtime state, worktrees, and OS metadata.
3. Add `project-config.json` with default values for DI, async, input, optional feature flags, Unity version, and review mode.
4. Add `production/review-mode.txt` with `lean` as the default.
5. Add `settings.json` with Claude Code permissions and hook registrations.
6. Add `CLAUDE.md` as the entry point and include the supporting docs through `@` references.
7. Add user-facing setup and quick-start documentation.

## Verification

- The `.claude/` directory contains commands, agents, rules, skills, hooks, docs, and state subfolders.
- `project-config.json` and `settings.json` parse as valid JSON.
- `.claude/CLAUDE.md` includes the supporting documentation files.
- The review mode file contains one valid value: `solo`, `lean`, or `full`.

## Expected Commit Groups

- Repository skeleton and ignore rules
- Project configuration
- Review mode default
- Settings and hook registration
- Entry point and supporting docs
- README, setup, and quick-start docs
