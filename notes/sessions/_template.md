# Session Note: [Short Title]

**Date**: YYYY-MM-DD
**Author**: [Your name or agent identifier]
**Related Issues**: [beads issue IDs, GitHub issue numbers, or ticket numbers]
**Related PRs**: [PR numbers if applicable]
**Status**: [In Progress | Completed | Abandoned]

---

## Context

Briefly describe:
- What problem are you investigating?
- What prompted this session? (bug, feature, architecture question, etc.)
- What are the constraints or requirements?

---

## Goal

What are you trying to achieve in this session?

Example: "Understand why sortKey values drift over time and evaluate normalization strategies."

---

## Investigation / Exploration

Document your work step-by-step. This is the "lab notebook" section—show your reasoning, attempts, and findings.

### Attempt 1: [Description]

**Hypothesis**: ...

**Approach**: ...

**Code/Commands**:
```swift
// Paste relevant code here
```

**Result**: ...

**Conclusion**: Success / Failed because ...

---

### Attempt 2: [Description]

**Hypothesis**: ...

**Approach**: ...

**Code/Commands**:
```bash
# Paste commands or scripts here
```

**Result**: ...

**Conclusion**: ...

---

### Attempt 3: [Description]

...

---

## Findings

Summarize what you learned:
- Key insights
- Root cause (if debugging)
- Pros/cons of different approaches (if exploring)
- Benchmarks or measurements (if performance-related)

---

## Decision

If this session led to a decision:
- What did you decide to do?
- Why? (trade-offs, constraints, benefits)
- Alternatives considered and why they were rejected

If this is a major architectural decision, also create an ADR in `docs/adr/`.

---

## Implementation Notes

If you implemented a solution:
- High-level summary of changes
- Files modified
- Commits or PRs created

Example:
```
- Modified `Persistence/Repositories/CardRepository.swift` to add background normalization
- Created `Services/CardReorderService.swift` for midpoint insertion logic
- Committed as: `feat: add background sortKey normalization (abc1234)`
```

---

## Next Steps

What remains to be done?
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

Link to beads issues if applicable.

---

## References

- Links to documentation, blog posts, Stack Overflow answers, etc.
- Related ADRs, CONTINUITY entries, or other session notes
- Commits, PRs, or issues created/referenced

---

## Key Takeaways

1-3 bullet points summarizing the most important lessons from this session. These may be promoted to `KNOWLEDGEBASE.md` later.

Example:
- SwiftData doesn't auto-update UI on sortKey changes; need explicit `.animation()` modifier
- Background normalization reduces CloudKit sync churn by ~80%
- Midpoint insertion is O(1) but requires periodic normalization to prevent floating-point drift
