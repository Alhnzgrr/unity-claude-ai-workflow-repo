# Auto-Loaded Skills

This file lists the skills that should be loaded by default or conditionally loaded by project configuration.

## Always Loaded (core/)

@.claude/skills/core/model-routing.md
@.claude/skills/core/unity-instincts/SKILL.md
@.claude/skills/core/unity-mcp-patterns/SKILL.md
@.claude/skills/core/context-management/SKILL.md

## Baseline Unity Architecture and Safety

@.claude/skills/unity-architecture/unity-clean-architecture/SKILL.md
@.claude/skills/unity-architecture/environment-view-separation/SKILL.md
@.claude/skills/unity-core/serialization-safety/SKILL.md
@.claude/skills/unity-core/editor-runtime-separation/SKILL.md
@.claude/skills/unity-core/input-system/SKILL.md

## Based on Project Configuration (project-config.json)

# di: vcontainer -> @.claude/skills/third-party/vcontainer/SKILL.md
# di: zenject -> @.claude/skills/third-party/zenject/SKILL.md
# async: unitask -> @.claude/skills/third-party/unitask/SKILL.md
# ecs: true -> @.claude/rules/ecs-dots.md
# addressables: true -> @.claude/skills/systems/addressables/SKILL.md
# xr: true -> @.claude/skills/systems/vr/SKILL.md

## Loaded on Demand

# simulation loop work -> @.claude/skills/unity-architecture/simulation-loop/SKILL.md
# pooling or frequent spawn/despawn -> @.claude/skills/unity-core/object-pooling/SKILL.md
# mobile risk -> @.claude/skills/unity-core/mobile-development/SKILL.md
# audio -> @.claude/skills/systems/audio/SKILL.md
# physics -> @.claude/skills/systems/physics/SKILL.md
# animation -> @.claude/skills/systems/animation/SKILL.md
# ui-toolkit -> @.claude/skills/systems/ui-toolkit/SKILL.md
# urp -> @.claude/skills/systems/urp-pipeline/SKILL.md
# cinemachine -> @.claude/skills/systems/cinemachine/SKILL.md
# shader -> @.claude/skills/systems/shader-graph/SKILL.md
