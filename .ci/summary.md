# ✅ CI Passed

**Run**: [20389926754](https://github.com/mattsq/minello/actions/runs/20389926754)
**Commit**: `9bc6ecf2`
**Branch**: `claude/ci-feedback-system-Jan4B`
**PR**: #12
**Time**: 2025-12-20T05:46:16.734243Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
2025-12-20 05:39:03.757 xcodebuild[2822:14258] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_05-39-0003.xcresult
xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.
Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the project file for invalid edits or unresolved source control conflicts.
```

#### Step: `validate-project`

```
9FE81F10FC0F5C68CD205C09 /* Release */,
);
defaultConfigurationIsVisible = 0;
defaultConfigurationName = Release;
};
/* End XCConfigurationList section */
};
rootObject = D0134771BAD2644D1A9FEB723C2633B0 /* Project object */;
}
```

### test

#### Step: `test`

```
2025-12-20 05:39:23.634 xcodebuild[7500:35863] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_05-39-0023.xcresult
xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.
Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the project file for invalid edits or unresolved source control conflicts.
```

### lint

#### Step: `swiftlint`

```
Error: Unknown option '--path'
Usage: swiftlint lint [<options>] [<paths> ...]
See 'swiftlint lint --help' for more information.
```

#### Step: `swiftformat`

```
(lint mode - no files will be changed.)
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:9:1: error: (trailingCommas) Add or remove trailing commas in comma-separated lists.
warning: sortedImports rule is deprecated. Use sortImports instead.
SwiftFormat completed in 0.06s.
```

## 🔍 Top Errors

- `2025-12-20 05:39:03.757 xcodebuild[2822:14258] Writing error result bundle to /var/folders/sm/xrr7tm`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the p`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `2025-12-20 05:39:23.634 xcodebuild[7500:35863] Writing error result bundle to /var/folders/sm/xrr7tm`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the p`
- `Error: Unknown option '--path'`
- `Usage: swiftlint lint [<options>] [<paths> ...]`
- `See 'swiftlint lint --help' for more information.`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:9:1:`
- `warning: sortedImports rule is deprecated. Use sortImports instead.`
- `SwiftFormat completed in 0.06s.`

## 📦 Artifacts

The following artifacts may be available:
- `test-results`
- `failed-snapshots`
- `lint-results`
- `build-logs`
- `test-logs`
- `lint-logs`

## 📄 Detailed Results

Full structured results: `.ci/summary.json` in branch `claude/ci-feedback-system-Jan4B`

---
<!-- ci-feedback -->