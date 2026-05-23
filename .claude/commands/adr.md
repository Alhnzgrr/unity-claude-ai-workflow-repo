# /adr

Creates an Architecture Decision Record.

## Usage

```
/adr <decision title>
```

Example: `/adr Decision to use Zenject instead of VContainer`

## Workflow

### Step 1 — Determine ADR Number

Scan the `docs/decisions/` folder, find the last number, add +1.

### Step 2 — Create ADR File

`docs/decisions/[NNN]-[slug].md`:

```markdown
# [NNN] — [Title]

**Date:** [YYYY-MM-DD]
**Status:** Accepted

## Context

[Why was this decision made? What problem does it solve?]

## Decision

[What was decided]

## Consequences

**Positive:**
- [advantages]

**Negative / Trade-off:**
- [disadvantages]

## Alternatives

[Options considered but not selected]
```

### Step 3 — Commit

```bash
git add docs/decisions/
git commit -m "docs: add ADR [NNN] - [slug]"
```
