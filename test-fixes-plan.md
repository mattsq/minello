# Test Failure Resolution Plan

## Executive Summary

The CI is currently failing due to **Swift parameter ordering errors** in the test suite. The build itself succeeds, but tests fail to compile because the `Card` model initializer is being called with arguments in the wrong order.

## Current Status

- **Build**: ✅ Passing
- **Tests**: ❌ Failing (compilation errors)
- **Lint**: ⚠️ Has issues (ignored per instructions)

## Root Cause Analysis

### Test Compilation Errors

**File**: `HomeCooked/Tests/Unit/BoardsRepositoryTests.swift`
**Lines**: 32 and 37
**Error**: `argument 'column' must precede argument 'sortKey'`

#### What's happening:

The `Card` initializer signature (from `Card.swift:18-29`) defines parameters in this order:
```swift
init(
    id: UUID = UUID(),
    title: String,
    details: String = "",
    due: Date? = nil,
    tags: [String] = [],
    checklist: [ChecklistItem] = [],
    column: Column? = nil,      // ← Line 25
    sortKey: Double = 0,        // ← Line 26
    createdAt: Date = Date(),
    updatedAt: Date = Date()
)
```

But the test is calling it with:
```swift
let card1 = Card(
    title: "Buy milk",
    sortKey: 100,      // ← Wrong order!
    column: column1
)
```

Swift requires that when using labeled arguments out of order, they must still maintain their relative ordering from the function signature. Since `column` is declared before `sortKey` in the initializer, it must also appear before `sortKey` in the call.

## Resolution Plan

### Phase 1: Fix Parameter Ordering (Priority: Critical)

**Files to modify:**
- `HomeCooked/Tests/Unit/BoardsRepositoryTests.swift`

**Changes required:**

1. **Line 29-33** (card1 initialization):
   ```swift
   // Current (WRONG):
   let card1 = Card(
       title: "Buy milk",
       sortKey: 100,
       column: column1
   )

   // Fixed (CORRECT):
   let card1 = Card(
       title: "Buy milk",
       column: column1,
       sortKey: 100
   )
   ```

2. **Line 34-38** (card2 initialization):
   ```swift
   // Current (WRONG):
   let card2 = Card(
       title: "Call plumber",
       sortKey: 200,
       column: column1
   )

   // Fixed (CORRECT):
   let card2 = Card(
       title: "Call plumber",
       column: column1,
       sortKey: 200
   )
   ```

**Validation:**
- Tests should compile successfully after this change
- Test assertions should pass (no changes to logic, only parameter order)

### Phase 2: Scan for Similar Issues

**Action items:**
1. Search codebase for other `Card(` initializations
2. Verify all calls use correct parameter ordering
3. Check if other model initializers have similar issues

**Search command:**
```bash
grep -r "Card(" HomeCooked/Tests/ --include="*.swift"
```

### Phase 3: Verification

**Steps:**
1. Run local build: `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' build`
2. Run local tests: `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test`
3. Verify all unit tests pass
4. Push changes and confirm CI passes

**Expected outcome:**
- ✅ Build passes
- ✅ Tests compile and pass
- ✅ CI shows green test job

## Risk Assessment

**Risk Level**: ⚠️ Low

- **Impact**: Minimal - only affects test code, not production code
- **Scope**: Limited to 2 lines in one test file
- **Complexity**: Trivial - simple parameter reordering
- **Regression Risk**: None - fixes compilation error without changing logic

## Additional Observations

### Build Job
The build job shows success with "** BUILD SUCCEEDED **" output. No action needed.

### Lint Job (Deferred)
While ignoring linting per instructions, noted issues for future reference:
- SwiftLint: No lintable files found (configuration issue)
- SwiftFormat: Import statement ordering in `HomeCookedApp.swift`

These should be addressed in a separate task/PR.

## Implementation Checklist

- [ ] Fix `card1` parameter ordering (line 29-33)
- [ ] Fix `card2` parameter ordering (line 34-38)
- [ ] Search for similar parameter ordering issues in test suite
- [ ] Run local build to verify compilation
- [ ] Run local tests to verify test passes
- [ ] Commit changes with message: `test: fix Card initializer parameter ordering in BoardsRepositoryTests`
- [ ] Push to branch
- [ ] Verify CI passes

## Timeline

**Estimated effort**: 5-10 minutes
- Parameter fixes: 2 minutes
- Codebase scan: 2 minutes
- Local verification: 3-5 minutes
- Commit/push: 1 minute

## Success Criteria

1. ✅ `BoardsRepositoryTests.swift` compiles without errors
2. ✅ All tests in `testCreateBoardWithColumnsAndCards()` pass
3. ✅ CI test job shows "success" with no failed steps
4. ✅ No regression in other tests

---

**Next Steps**: Implement Phase 1 fixes immediately, then proceed with verification phases.
