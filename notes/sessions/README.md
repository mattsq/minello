# Session Notes

**Purpose**: Long-form session notes for deep investigations, debugging sessions, architecture explorations, or any detailed work that shouldn't clutter `CONTINUITY.md`.

---

## When to Create a Session Note

Create a session note here when:
- **Deep investigation**: Researching a complex problem, exploring multiple solutions
- **Complex debugging**: Multi-step debugging with many attempts and hypotheses
- **Architecture exploration**: Design spikes, prototyping, evaluating architectural options
- **Refactoring sessions**: Large-scale refactoring with step-by-step reasoning
- **Research**: Learning a new technology, API, or pattern relevant to the project

**Don't create a session note for**:
- Simple bug fixes (add to CONTINUITY session log instead)
- Routine feature implementation (add to CONTINUITY session log instead)
- Short decisions (add to CONTINUITY session log instead)

---

## How to Create a Session Note

1. **Copy the template**:
   ```bash
   cp notes/sessions/_template.md notes/sessions/YYYY-MM-DD-topic.md
   ```
   Replace `YYYY-MM-DD` with today's date and `topic` with a short, descriptive slug (e.g., `2025-12-21-swiftdata-sync-debug`)

2. **Fill in the template**: Document your investigation, reasoning, attempts, and conclusions

3. **Link from CONTINUITY**: Add a brief mention in `CONTINUITY.md` session log with a link to the full note:
   ```markdown
   ### 2025-12-21: Debugged SwiftData sync issue
   **What Changed**: Fixed race condition in CloudKit sync (see [notes/sessions/2025-12-21-swiftdata-sync-debug.md](notes/sessions/2025-12-21-swiftdata-sync-debug.md))
   ```

4. **Promote key findings**: If the session reveals durable lessons, promote them to `KNOWLEDGEBASE.md` (Pitfalls, Workflows, etc.)

---

## Archiving Old Sessions

Once `CONTINUITY.md` session log grows beyond ~10 entries, consider:
- Moving old session log entries to a monthly archive: `notes/sessions/YYYY-MM-archive.md`
- Keeping session notes here indefinitely (they're already organized by date and don't clutter the main docs)

---

## Example Session Notes

**Good examples**:
- `2025-12-20-investigate-sortkey-drift.md` – Detailed analysis of why sortKey values drift over time, benchmarks of normalization strategies
- `2025-12-15-cloudkit-sharing-spike.md` – Exploration of CloudKit sharing API, code experiments, pros/cons of different approaches
- `2025-12-10-trello-import-edge-cases.md` – Debugging rare edge cases in Trello JSON import, examples of malformed input

**Bad examples** (these belong in CONTINUITY.md instead):
- `2025-12-21-added-tests.md` – Too trivial for a session note
- `2025-12-18-fixed-typo.md` – Not a deep investigation
- `2025-12-16-ran-linter.md` – Routine work, not noteworthy

---

## Tips

- **Use descriptive filenames**: `YYYY-MM-DD-topic.md` makes it easy to find notes later
- **Link liberally**: Reference commits, PRs, issues, CONTINUITY entries, ADRs
- **Include code snippets**: Paste relevant code, terminal output, error messages
- **Show your work**: Document hypotheses, attempts, and why they failed (valuable for future debugging)
- **Conclude with a summary**: End each note with "Key Takeaways" or "Next Steps"

---

## Session Note Template

See `_template.md` for the recommended structure.
