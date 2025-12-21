# Architecture Decision Records (ADRs)

## What is an ADR?

An **Architecture Decision Record** (ADR) captures a significant architectural or design decision made during the project, along with the context and consequences of that decision.

ADRs help:
- Document the "why" behind major technical choices
- Provide context for future maintainers
- Surface trade-offs and alternatives considered
- Enable informed future decisions

## When to Create an ADR

Create an ADR when you make a decision that:
- Affects the overall system architecture (e.g., persistence layer, sync strategy)
- Introduces a new technology or framework
- Establishes a pattern or convention used across the codebase
- Has long-term implications (hard to reverse later)
- Resolves a significant trade-off between competing concerns

**Examples that deserve an ADR**:
- "Use SwiftData instead of Core Data"
- "Implement Repository pattern for persistence abstraction"
- "Use floating sortKey with midpoint insertion for card reordering"
- "Choose beads for git-native issue tracking"
- "CloudKit last-write-wins conflict resolution"

**Examples that do NOT need an ADR**:
- Naming a variable or function
- Choosing a specific UI layout (unless it establishes a pattern)
- Fixing a bug (unless it reveals a design flaw)
- Refactoring without changing behavior

## How to Create an ADR

1. **Copy the template**:
   ```bash
   cp docs/adr/0000-template.md docs/adr/XXXX-your-decision-title.md
   ```
   Replace `XXXX` with the next sequential number (e.g., `0001`, `0002`, etc.)

2. **Fill in the template**:
   - **Context**: What problem are you solving? What constraints exist?
   - **Decision**: What did you decide to do?
   - **Alternatives**: What other options did you consider? Why did you reject them?
   - **Consequences**: What are the positive and negative outcomes of this decision?
   - **Links**: Reference related PRs, issues, commits, or other ADRs

3. **Keep it concise**: Aim for 1-2 pages max. Focus on "why" over "how".

4. **Update KNOWLEDGEBASE.md**:
   - Add the decision to the "Architecture & Decisions" section
   - Link to the ADR

5. **Commit with PR**: Include ADR in the PR that implements the decision.

## ADR Lifecycle

- **Proposed**: Decision under discussion (draft ADR in PR)
- **Accepted**: Decision implemented and merged
- **Superseded**: Replaced by a later decision (link to new ADR)
- **Deprecated**: No longer recommended but still in use
- **Rejected**: Decided against (keep for historical context)

Mark status at the top of each ADR.

## Existing ADRs

_(None yet—add links here as ADRs are created)_

**Planned ADRs** (mentioned in KNOWLEDGEBASE.md):
- 0001: Repository pattern for persistence abstraction
- 0002: Floating sortKey with midpoint insertion
- 0003: Beads for issue tracking (git-native, distributed)

---

## References

- [Architectural Decision Records (ADR)](https://adr.github.io/)
- [Michael Nygard's ADR template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/templates/decision-record-template-by-michael-nygard/index.md)
