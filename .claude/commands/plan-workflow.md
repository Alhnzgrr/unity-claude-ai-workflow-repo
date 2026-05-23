# /plan-workflow

Breaks the TDD into implementation phases and tasks. Produces WORKFLOW.md.

## Usage

```
/plan-workflow
```

## Prerequisite

`docs/TDD.md` must exist.

## Workflow

### Step 1 — Read TDD

Read `docs/TDD.md`. Understand all systems and dependencies.

### Step 2 — Determine Phases

Determine phases according to dependency order:
- Phase 1: Foundation (Framework, EventBus, DI scaffold)
- Phase 2: Core systems (those with fewer dependencies first)
- Phase 3: Feature systems
- Phase 4: UI & polish
- Phase 5: Integration & QA

### Step 3 — Write Tasks

Tasks for each phase:
- Independent tasks → mark with `parallel_group`
- For each task: description, agent type, input/output, acceptance criteria

### Step 4 — Create WORKFLOW.md

Write to `docs/WORKFLOW.md`:

```markdown
# WORKFLOW — [Project Name]

## Phase 1: Foundation

### Task 1.1: EventBus Implementation
- **Agent:** coder
- **Input:** IEventBus interface definition
- **Output:** EventBus.cs (Assets/_Framework/Events/)
- **Acceptance:** EditMode tests passing
- **parallel_group:** foundation

### Task 1.2: Logger Implementation
- **Agent:** coder
- **Input:** ILogger interface definition
- **Output:** UnityLogger.cs (Assets/_Framework/Logging/)
- **Acceptance:** EditMode tests passing
- **parallel_group:** foundation

## Phase 2: Core Systems
...
```

### Step 5 — Commit

```bash
git add docs/WORKFLOW.md
git commit -m "docs: add WORKFLOW.md with phased implementation plan"
```

## Next Step

Preview with `/dry-run` or execute with `/orchestrate`.
