# Model Routing

Use the smallest model tier that can make the decision safely. Keep the agent layer compact; route package and subsystem details through skills instead of spawning more agents.

## Model Tiers

| Tier | When |
|---|---|
| light | Documentation cleanup, summaries, index updates, simple read-only checks |
| normal | Implementation, review, debugging, tests, validation, most Unity work |
| heavy | Architecture design, high-risk dependency decisions, broad migrations |

## Agent Tier Mapping

| Agent | Default tier | Notes |
|---|---|---|
| `docs-maintainer` | light | Use for README, skills, rules, indexes, ADRs, and learned patterns. |
| `unity-implementer` | normal | Can handle small fixes and full implementation. Escalate only when design is unclear. |
| `code-reviewer` | normal | Use stricter depth in `full` mode instead of spawning a second reviewer. |
| `test-validator` | normal | Use for test authoring, compile checks, hook checks, and build validation. |
| `performance-auditor` | normal | Use only when performance is central to the task. |
| `project-architect` | heavy | Use for system design, discovery, package analysis, dependency boundaries, and migration planning. |

## Complexity Score

```text
0.0-0.3 -> light or normal
0.4-0.6 -> normal
0.7-1.0 -> heavy design pass, then normal implementation
```

Complexity signals:

- New module: +0.3
- Multiple systems affected: +0.2
- ECS, Addressables, networking, mobile, or VR risk: +0.2
- Requires tests: +0.1
- Modifies existing code: +0.1
- Single file and single method: usually 0.1

## Routing Rule

Spawn another agent only when the next step needs a different decision responsibility. Do not spawn a new agent just because a named skill exists.

