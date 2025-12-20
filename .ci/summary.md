# ✅ CI Passed

**Run**: [20391677269](https://github.com/mattsq/minello/actions/runs/20391677269)
**Commit**: `73ff705a`
**Branch**: `claude/fix-ci-summary-issues-zB4gO`
**PR**: #14
**Time**: 2025-12-20T08:19:51.986760Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
2025-12-20 08:19:18.244 xcodebuild[13650:61645] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_08-19-0018.xcresult
xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.
Reason: The project ‘HomeCooked’ is damaged and cannot be opened. Examine the project file for invalid edits or unresolved source control conflicts.
Path: /Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj
Exception: -[PBXFileReference buildPhase]: unrecognized selector sent to instance 0x6000024ce220
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
2025-12-20 08:19:35.315 xcodebuild[2651:13668] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_08-19-0035.xcresult
xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.
Reason: The project ‘HomeCooked’ is damaged and cannot be opened. Examine the project file for invalid edits or unresolved source control conflicts.
Path: /Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj
Exception: -[PBXFileReference buildPhase]: unrecognized selector sent to instance 0x6000015a7dc0
```

### lint

#### Step: `swiftlint`

```
Linting Swift files in current working directory
Error: No lintable files found at paths: ''
```

#### Step: `swiftformat`

```
Running SwiftFormat...
(lint mode - no files will be changed.)
SwiftFormat completed in 0.08s.
0/28 files require formatting.
```

## 🔍 Top Errors

- `2025-12-20 08:19:18.244 xcodebuild[13650:61645] Writing error result bundle to /var/folders/sm/xrr7t`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened. Examine the project file for inval`
- `Path: /Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj`
- `Exception: -[PBXFileReference buildPhase]: unrecognized selector sent to instance 0x6000024ce220`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `2025-12-20 08:19:35.315 xcodebuild[2651:13668] Writing error result bundle to /var/folders/sm/xrr7tm`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened. Examine the project file for inval`
- `Path: /Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj`
- `Exception: -[PBXFileReference buildPhase]: unrecognized selector sent to instance 0x6000015a7dc0`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `Running SwiftFormat...`
- `(lint mode - no files will be changed.)`
- `SwiftFormat completed in 0.08s.`
- `0/28 files require formatting.`

## 📦 Artifacts

The following artifacts may be available:
- `test-results`
- `failed-snapshots`
- `lint-results`
- `build-logs`
- `test-logs`
- `lint-logs`

## 📄 Detailed Results

Full structured results: `.ci/summary.json` in branch `claude/fix-ci-summary-issues-zB4gO`

---
<!-- ci-feedback -->