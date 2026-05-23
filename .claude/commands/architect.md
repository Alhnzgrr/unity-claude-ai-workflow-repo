# /architect

Generates a Technical Design Document from `docs/GDD.md`.

## Usage

```text
/architect
```

## Prerequisite

`docs/GDD.md` must exist. If not, run `/game-idea` first.

## Workflow

### Step 1 - Read GDD

Read `docs/GDD.md` and identify the core loop, major mechanics, target platforms, and constraints.

### Step 2 - project-architect

Spawn `project-architect`:

- Identify systems and ownership boundaries.
- Define module structure: Interface, Service, Config, Installer, Events, and Provider when needed.
- Draw dependency direction and data flow.
- Challenge the weakest assumption in the design before writing the final TDD.

### Step 3 - Create TDD

Write to `docs/TDD.md`:

```markdown
# Technical Design Document - [Game Name]

## Systems

### [SystemName]
**Responsibility:** [single sentence]
**Interface:** I[SystemName]Service
**Dependencies:** [other interfaces]
**Events:** [published and subscribed]

## Module Structure
[List of files per module]

## Dependency Graph
[Text or diagram]

## Data Flow
[Sequence for important scenarios]

## Risks
[Identified risks and mitigations]
```

### Step 4 - Commit

Ask for approval before committing `docs/TDD.md`.

## Next Step

When TDD is ready, create the implementation plan with `/plan-workflow`.

