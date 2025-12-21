# Continuity

**Purpose**: Track session-to-session state, decisions, and progress. Ephemeral details live here; durable lessons get promoted to `KNOWLEDGEBASE.md`.

---

## Current Focus

**Goal**: Add agent memory system to repository (KNOWLEDGEBASE, CONTINUITY, ADR scaffolding, PR template, agent workflow docs)

**Next 3 Steps**:
1. Create ADR scaffolding in `docs/adr/`
2. Update `CLAUDE.md` to reference new memory system
3. Create PR template and agent workflow guide

**Current Risks / Open Questions**:
- None currently

---

## Session Log

### 2025-12-21: Initial agent memory system setup

**What Changed**:
- Created `KNOWLEDGEBASE.md` with comprehensive project knowledge (TL;DR, project map, build/test commands, conventions, architecture decisions, workflows, pitfalls, glossary)
- Created `CONTINUITY.md` (this file) for session tracking
- Planned ADR scaffolding, PR template, agent workflow guide

**Decisions Made**:
- Use `KNOWLEDGEBASE.md` for durable knowledge (how-to, conventions, architecture)
- Use `CONTINUITY.md` for session state (current focus, recent changes, decisions)
- Keep both files concise; move long-form notes to `notes/sessions/`
- Integrate memory upkeep into PR template (gentle nudges, not enforcement)

**Failures Tried / Ruled Out**:
- None yet

**Next Steps**:
- Create `docs/adr/` with README and template
- Update `CLAUDE.md` to add memory system section at top
- Create `.github/pull_request_template.md` with memory upkeep checklist
- Create `docs/agent-workflow.md` with session start/end workflow
- Create `notes/sessions/` structure for optional long-form notes
- Update `README.md` to link to agent workflow docs

---

## How to Use This File

**At session start**:
1. Read "Current Focus" to understand what's in flight
2. Scan recent session log entries (top 2-3) for context
3. Check "Current Risks / Open Questions" for blockers

**During session**:
- Update "Current Focus" if goals/steps change
- Add to "Current Risks / Open Questions" as they arise

**At session end**:
1. Add new session log entry (date, what changed, decisions, failures, next steps)
2. Update "Current Focus" with new goal/next steps
3. Promote durable lessons to `KNOWLEDGEBASE.md` (architecture, conventions, pitfalls)
4. Archive old entries if log grows beyond ~10 sessions (move to `notes/sessions/YYYY-MM.md`)

**When to create a session note in `notes/sessions/`**:
- Deep investigation/research that shouldn't clutter CONTINUITY
- Long debugging session with multiple attempts
- Complex refactoring with step-by-step reasoning
- Architecture exploration / design spikes

**When to promote to KNOWLEDGEBASE**:
- Discovered a recurring pitfall (add to "Pitfalls / Sharp Edges")
- Made an architectural decision (add to "Architecture & Decisions" + create ADR)
- Established a new convention (add to "Conventions")
- Learned a new workflow pattern (add to "Common Workflows")
