# /learn

Discovers project-specific patterns and saves them under skills/learned/.

## Usage

```
/learn [optional: topic]
```

## When to Use

- When a pattern has been repeated 3+ times in the project
- When the same mistake has been made more than once
- When a project-specific convention has emerged

## Workflow

### Step 1 — Detect Pattern

Ask or observe one of the following:
- "Where else has this pattern been used?"
- "Does this error exist anywhere else?"

Scan the codebase with `unity-scout`.

### Step 2 — Create Skill

`skills/learned/<pattern-name>.md`:

```markdown
---
name: [pattern-name]
description: [when to use — one sentence]
project-specific: true
---

# [Pattern Name]

## When

[When is this pattern applied]

## How

[Explanation with code example]

## Watch Out

[Things to avoid]
```

### Step 3 — Update auto-loaded-skills.md

Add to `.claude/docs/auto-loaded-skills.md`:
```
@.claude/skills/learned/[pattern-name].md
```

### Step 4 — Commit

```bash
git add .claude/skills/learned/ .claude/docs/auto-loaded-skills.md
git commit -m "docs: learn [pattern-name] pattern"
```
