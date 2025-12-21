# Agent Workflow Guide

**Purpose**: Detailed instructions for AI agents working on this repository, covering session start, ongoing work, memory management, and session end.

---

## Overview

This repository uses a **layered memory system** to enable context sharing across agent sessions:

1. **CLAUDE.md** – Primary entrypoint; stable instructions, tickets, beads workflow
2. **KNOWLEDGEBASE.md** – Durable knowledge (architecture, conventions, workflows, pitfalls, glossary)
3. **CONTINUITY.md** – Session-to-session state (current focus, recent changes, decisions, next steps)
4. **docs/adr/** – Architecture Decision Records (major "why" decisions)
5. **notes/sessions/** – Optional long-form session notes (deep dives, debugging logs)

**Key principle**: Keep **KNOWLEDGEBASE** and **CONTINUITY** concise. Move verbose details to **notes/sessions/**.

---

## Starting a Session

### 1. Read the Entrypoint

Start with **CLAUDE.md** (if it exists, else **AGENTS.md**):
- Understand project overview, ground rules, conventions
- Review tickets if assigned a specific task
- Note beads workflow and memory system overview

### 2. Load Durable Knowledge

Read **KNOWLEDGEBASE.md** to understand:
- Project structure (key directories and files)
- How to build, test, run, and lint
- Coding conventions and architectural decisions
- Common workflows (add feature, fix bug, release)
- Known pitfalls and sharp edges

**Tip**: If you're working on a specific feature (e.g., persistence, UI), focus on the relevant sections. You don't need to memorize everything—KNOWLEDGEBASE is a reference, not a script.

### 3. Load Session Context

Read **CONTINUITY.md** to answer:
- What's the current focus? (goal, next 3 steps)
- What are the current risks or blockers?
- What happened in the last 2-3 sessions? (scan session log)

### 4. Check for Open Work

Use beads to see what's available:

```bash
# In Claude Code Web environments, use full path + flags:
/root/go/bin/bd --no-db ready --json

# Or see all issues:
/root/go/bin/bd --no-db list --json

# Show details for a specific issue:
/root/go/bin/bd --no-db show <issue-id> --json
```

**Choose a task**:
- If assigned a specific ticket (e.g., "Implement ticket 2"), create or claim the corresponding beads issue
- If exploring/debugging, create a new issue: `/root/go/bin/bd create "Task title" -d "Description" -p 1`

**Claim the task**:

```bash
/root/go/bin/bd update <issue-id> --status in_progress
```

### 5. Update CONTINUITY.md

If starting a new goal (not continuing existing work):
- Update "Current Focus" → Goal, Next 3 Steps, Risks/Questions
- If risks/blockers exist, list them clearly

---

## During the Session

### Work Discipline

1. **Follow the plan**: Execute the "Next 3 Steps" from CONTINUITY.md or the task description
2. **Create issues as you go**: Discovered a bug? Missing feature? Tech debt? Create a beads issue immediately
3. **Track dependencies**: If task B depends on task A, link them: `/root/go/bin/bd dep add <task-B> <task-A>`
4. **Test frequently**: Don't batch all testing to the end; run unit/integration tests as you implement
5. **Commit incrementally**: Small, logical commits with Conventional Commits messages (e.g., `feat: add sortKey to Card model`)

### When to Update CONTINUITY.md

Update **during** the session if:
- You make a significant architectural decision (also create/update ADR)
- You discover a blocker or risk (add to "Current Risks / Open Questions")
- You change the goal or next steps significantly

**Don't over-update**: CONTINUITY is for major decisions and state changes, not every line of code. Save detailed notes for `notes/sessions/` if needed.

### When to Create a Session Note (notes/sessions/)

Create a long-form session note if:
- Deep investigation/research (e.g., "Why does SwiftData sync fail intermittently?")
- Complex debugging session with many attempts
- Architecture exploration / design spike
- Anything that would clutter CONTINUITY with too much detail

**Template**: Copy `notes/sessions/_template.md` and rename to `YYYY-MM-DD-topic.md`.

### Avoiding Bloat

**KNOWLEDGEBASE.md**:
- Keep each section brief (aim for <15 lines per subsection)
- If a section grows too long, split it or move detail to an ADR
- Prune outdated information (e.g., if a pitfall is resolved, move it to "Fixed Issues" or remove)

**CONTINUITY.md**:
- Archive old session log entries if log grows beyond ~10 sessions
  - Move to `notes/sessions/YYYY-MM-archive.md` or delete if no longer relevant
- Keep "Current Focus" focused (1 goal, 3 steps, <5 risks)

**ADRs**:
- One decision per ADR; don't bundle multiple unrelated decisions
- If a decision is superseded, mark the old ADR as "Superseded by ADR-XXXX" and create a new one

---

## Memory Management: What Goes Where?

| Type of Information | Where It Lives | Example |
|---------------------|----------------|---------|
| Architectural decision (lasting) | KNOWLEDGEBASE.md + ADR | "Use Repository pattern for persistence" |
| Code convention | KNOWLEDGEBASE.md (Conventions) | "No magic strings; use enums" |
| Build/test commands | KNOWLEDGEBASE.md (Build/Test) | `xcodebuild -scheme HomeCooked test` |
| Recurring pitfall | KNOWLEDGEBASE.md (Pitfalls) | "SwiftUI List DnD quirks → use LazyVStack" |
| Current goal/next steps | CONTINUITY.md (Current Focus) | "Implement ticket 2: Kanban drag-drop" |
| Recent session summary | CONTINUITY.md (Session Log) | "2025-12-21: Added sortKey migration, fixed tests" |
| Decision made this session | CONTINUITY.md (Session Log → Decisions Made) | "Chose midpoint insertion over array reordering" |
| Deep debugging / exploration | notes/sessions/YYYY-MM-DD-topic.md | "Investigating SwiftData race condition" |
| Major architectural "why" | docs/adr/XXXX-title.md | "ADR-0002: Floating sortKey with midpoint insertion" |

### Promotion Flow

```
Session note (notes/sessions/)
    ↓ (if durable/recurring)
CONTINUITY.md (session log)
    ↓ (if it becomes a pattern/convention)
KNOWLEDGEBASE.md (conventions, pitfalls, workflows)
    ↓ (if it's a major decision)
ADR (docs/adr/)
```

**Example**:
1. You debug a SwiftData sync issue → write detailed notes in `notes/sessions/2025-12-21-swiftdata-sync-debug.md`
2. You discover the root cause and fix it → add session log entry in CONTINUITY.md under "Decisions Made"
3. The issue reveals a recurring pitfall (e.g., "CloudKit sync fails if schema migration in progress") → add to KNOWLEDGEBASE.md "Pitfalls / Sharp Edges"
4. The fix involves a new architectural pattern (e.g., "queue migrations before sync") → create ADR-0004

---

## Ending a Session

### 1. Complete Open Work

- Finish current implementation (or reach a stable checkpoint)
- Run tests, lint, and build to ensure nothing is broken
- Commit all changes with clear messages

### 2. Update CONTINUITY.md

Add a **session log entry** at the top of the "Session Log" section:

```markdown
### YYYY-MM-DD: [Brief session title]

**What Changed**:
- Implemented X
- Fixed Y
- Refactored Z

**Decisions Made**:
- Chose approach A over B because [reason]
- Decided to defer feature C until ticket 5

**Failures Tried / Ruled Out**:
- Tried X but hit issue Y (ruled out)
- Considered pattern Z but rejected due to [reason]

**Next Steps**:
- Finish implementation of feature X
- Add integration tests for Y
- Address TODO in Z
```

### 3. Update "Current Focus"

Refresh the "Current Focus" section:
- **Goal**: What's the active objective? (unchanged if continuing; new goal if switching tasks)
- **Next 3 Steps**: What are the immediate next actions?
- **Current Risks / Open Questions**: Any blockers? Unresolved questions?

### 4. Promote Durable Lessons to KNOWLEDGEBASE

Review your session log entry and ask:
- Did I discover a new convention? → Add to KNOWLEDGEBASE "Conventions"
- Did I hit a recurring pitfall? → Add to KNOWLEDGEBASE "Pitfalls / Sharp Edges"
- Did I make an architectural decision? → Add to KNOWLEDGEBASE "Architecture & Decisions" + create ADR
- Did I learn a new workflow trick? → Add to KNOWLEDGEBASE "Common Workflows"

**Keep it concise**: KNOWLEDGEBASE entries should be 1-3 sentences + bullet points.

### 5. Close Completed Beads Issues

For each task you finished:

```bash
/root/go/bin/bd close <issue-id> --reason "Completed in commit abc1234 / PR #42"
```

**Sync** (auto-syncs on write in most cases, but manual sync is optional):

```bash
bd sync  # May fail in Claude Code Web—not critical
```

### 6. Archive Old Sessions (if needed)

If CONTINUITY.md's session log has >10 entries:
- Move oldest entries to `notes/sessions/YYYY-MM-archive.md`
- Keep the last 5-7 sessions in CONTINUITY for quick reference

### 7. Commit Memory Updates

If you updated KNOWLEDGEBASE, CONTINUITY, or created ADRs:

```bash
git add KNOWLEDGEBASE.md CONTINUITY.md docs/adr/ notes/
git commit -m "docs: update agent memory after [session topic]"
```

---

## Definition of Done (Memory)

A session is "done" from a memory perspective if:

- [ ] CONTINUITY.md has a session log entry summarizing what happened
- [ ] "Current Focus" is updated with accurate next steps
- [ ] Durable lessons are promoted to KNOWLEDGEBASE.md (if any)
- [ ] ADR created/updated if architectural decision was made
- [ ] Beads issues are closed with completion notes
- [ ] Memory files are committed to git

---

## Tips for Effective Memory Use

### For New Agents

- **Don't skip KNOWLEDGEBASE**: It contains critical context (conventions, pitfalls, workflows). Reading it saves time and prevents mistakes.
- **CONTINUITY tells you what's in flight**: If you start mid-project, CONTINUITY.md is your friend. It answers "What was the previous agent doing?"
- **Use beads liberally**: Create issues for everything (bugs, features, tech debt). Close them when done. This creates a clear history.

### For Continuing Work

- **Check CONTINUITY first**: Don't re-explore if the previous session already documented the state.
- **Update incrementally**: Add to CONTINUITY as you make decisions, not just at session end.
- **Avoid duplicating KNOWLEDGEBASE**: If the answer is already in KNOWLEDGEBASE, reference it instead of repeating.

### For Long-Running Projects

- **Prune regularly**: Archive old CONTINUITY entries; remove outdated KNOWLEDGEBASE sections.
- **Summarize monthly**: Create a `notes/sessions/YYYY-MM-summary.md` with high-level progress.
- **Link everything**: ADRs → PRs → issues → commits. Cross-references make the history traceable.

---

## Troubleshooting

### "I don't know where to put this information"

Use this decision tree:

1. **Is it a fact about how the system works (architecture, conventions, workflows)?**
   → KNOWLEDGEBASE.md

2. **Is it about the current state of work (goal, next steps, recent decisions)?**
   → CONTINUITY.md

3. **Is it a deep dive / long-form exploration?**
   → notes/sessions/YYYY-MM-DD-topic.md

4. **Is it a major architectural decision with lasting impact?**
   → docs/adr/XXXX-title.md (also add summary to KNOWLEDGEBASE)

5. **Is it a specific task or bug?**
   → Create a beads issue (`/root/go/bin/bd create`)

### "CONTINUITY.md is getting too long"

- Archive old session log entries to `notes/sessions/YYYY-MM-archive.md`
- Keep only the last 5-7 sessions in CONTINUITY
- Summarize multiple small sessions into one monthly summary entry

### "KNOWLEDGEBASE.md has duplicate information"

- Consolidate overlapping sections
- Use links: "See Build/Test section for commands" instead of repeating
- If a section is >20 lines, consider splitting or moving to an ADR

### "I made a decision but don't know if it needs an ADR"

Ask:
- Will this decision affect future development? (Yes → ADR)
- Is it hard to reverse? (Yes → ADR)
- Is it a convention or style choice? (No → just update KNOWLEDGEBASE "Conventions")
- Is it a bug fix? (No → session log in CONTINUITY is enough)

When in doubt, create the ADR. It's easier to mark it "Rejected" later than to forget why a decision was made.

---

## Example Session Flow

### Session Start

1. Read CLAUDE.md (agent instructions)
2. Read KNOWLEDGEBASE.md (project architecture, conventions)
3. Read CONTINUITY.md (current focus: "Implement ticket 2: Kanban drag-drop")
4. Check beads: `/root/go/bin/bd --no-db ready --json`
5. Claim task: `/root/go/bin/bd update minello-abc123 --status in_progress`

### During Session

6. Implement drag-and-drop with sortKey midpoint insertion
7. Discover a bug: SwiftData doesn't auto-update UI on sortKey change
   - Create issue: `/root/go/bin/bd create "Bug: UI doesn't update on sortKey change" -d "..." -p 0`
8. Fix bug by adding `.animation()` modifier
9. Decide to use background normalization to prevent sortKey drift
   - Add decision to CONTINUITY.md (informal note for now)
10. Write unit + integration tests
11. Commit: `feat: add drag-and-drop with sortKey midpoint insertion`

### Session End

12. Add session log to CONTINUITY.md:
    ```markdown
    ### 2025-12-21: Implemented drag-and-drop for kanban cards
    **What Changed**: Added sortKey midpoint insertion, background normalization
    **Decisions Made**: Use background task for normalization (prevents UI jank)
    **Next Steps**: Add snapshot tests, implement haptics on drop
    ```
13. Promote decision to KNOWLEDGEBASE.md:
    - Add to "Architecture & Decisions": "Floating sortKey with background normalization"
    - Add to "Pitfalls": "SwiftData UI updates require explicit `.animation()` for sortKey changes"
14. Create ADR-0002: "Floating sortKey with midpoint insertion" (optional but recommended)
15. Close issue: `/root/go/bin/bd close minello-abc123 --reason "Completed in commit def4567"`
16. Commit memory updates: `git commit -m "docs: update memory after drag-drop implementation"`

---

## Summary

**Read this workflow guide when**:
- You're a new agent starting on the project
- You're unsure where to document something
- You want to understand the memory system design

**Refer to CLAUDE.md for**:
- Project overview, tickets, ground rules

**Refer to KNOWLEDGEBASE.md for**:
- How to build, test, and run the project
- Code conventions, architecture, workflows

**Refer to CONTINUITY.md for**:
- What's currently in progress
- What happened in recent sessions

**Refer to docs/adr/ for**:
- Why major architectural decisions were made

Together, these files enable seamless handoffs between agents and across sessions.
