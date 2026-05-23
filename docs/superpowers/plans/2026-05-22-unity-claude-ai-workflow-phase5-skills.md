# Unity Claude AI Workflow - Phase 5: Skills

## Goal

Create the core, systems, and third-party skill files used by agents and commands.

## Skill Layout

```text
.claude/skills/
├── core/
├── systems/
├── third-party/
└── learned/
```

## Core Skills

- `.claude/skills/core/model-routing.md`
- `.claude/skills/core/unity-instincts/SKILL.md`
- `.claude/skills/core/unity-mcp-patterns/SKILL.md`
- `.claude/skills/core/context-management/SKILL.md`

Core skills are always available. They define model-tier routing, common Unity decisions, MCP usage patterns, review mode behavior, checkpointing, and context hygiene.

## Systems Skills

- `.claude/skills/systems/audio/SKILL.md`
- `.claude/skills/systems/physics/SKILL.md`
- `.claude/skills/systems/animation/SKILL.md`
- `.claude/skills/systems/ui-toolkit/SKILL.md`
- `.claude/skills/systems/urp-pipeline/SKILL.md`
- `.claude/skills/systems/cinemachine/SKILL.md`
- `.claude/skills/systems/shader-graph/SKILL.md`
- `.claude/skills/systems/addressables/SKILL.md`
- `.claude/skills/systems/vr/SKILL.md`

Systems skills are loaded when the current task touches the relevant Unity system or when project configuration enables a feature such as Addressables or XR.

## Third-Party Skills

- `.claude/skills/third-party/vcontainer/SKILL.md`
- `.claude/skills/third-party/zenject/SKILL.md`
- `.claude/skills/third-party/unitask/SKILL.md`
- `.claude/skills/third-party/dotween/SKILL.md`
- `.claude/skills/third-party/textmeshpro/SKILL.md`

Third-party skills are loaded according to `project-config.json` and package detection from `Packages/manifest.json`.

## Auto-Loaded Skills Index

`.claude/docs/auto-loaded-skills.md` lists always-loaded core skills and documents conditional loading rules:

- `di: vcontainer` loads VContainer guidance.
- `di: zenject` loads Zenject guidance.
- `async: unitask` loads UniTask guidance.
- `addressables: true` loads Addressables guidance.
- `xr: true` loads VR guidance.

## Verification

- Core contains 4 skill documents.
- Systems contains 9 `SKILL.md` files.
- Third-party contains 5 `SKILL.md` files.
- The auto-loaded skills index references the required core files and conditional feature files.
