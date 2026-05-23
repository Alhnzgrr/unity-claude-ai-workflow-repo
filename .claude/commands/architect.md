# /architect

Generates a Technical Design Document (TDD) from the GDD. Adversarial review with unity-critic.

## Usage

```
/architect
```

## Prerequisite

`docs/GDD.md` must exist. If not, run `/game-idea` first.

## Workflow

### Step 1 — Read GDD

Read `docs/GDD.md`. Understand the core loop and mechanics.

### Step 2 — Spawn unity-architect

Do technical design with the `unity-architect` agent:
- Identify systems (AudioSystem, PlayerSystem, EnemySystem...)
- Module structure for each system: Interface + Service + Config + Installer + Events
- Draw the dependency graph
- Define the data flow

### Step 3 — Adversarial Review with unity-critic

Spawn the `unity-critic` agent:
- Find the weakest point in the design
- Ask one sharp question
- unity-architect responds, strengthens the design
- Maximum 3 rounds

### Step 4 — Create TDD

Write to `docs/TDD.md`:

```markdown
# Technical Design Document — [Game Name]

## Systems

### [SystemName]
**Responsibility:** [single sentence]
**Interface:** I[SystemName]Service
**Dependencies:** [other interfaces]
**Events:** [published and subscribed]

## Module Structure
[List of 5 files per module]

## Dependency Graph
[Text or diagram]

## Data Flow
[Sequence for important scenarios]

## Risks
[Identified risks and mitigations]
```

### Step 5 — Commit

```bash
git add docs/TDD.md
git commit -m "docs: add Technical Design Document"
```

## Next Step

When TDD is ready: create the implementation plan with `/plan-workflow`.
