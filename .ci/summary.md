# ✅ CI Passed

**Run**: [20390556181](https://github.com/mattsq/minello/actions/runs/20390556181)
**Commit**: `28e8a2c1`
**Branch**: `claude/plan-ci-fixes-ygU3O`
**PR**: #13
**Time**: 2025-12-20T06:36:27.666689Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
2025-12-20 06:35:57.100 xcodebuild[17935:78903] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_06-35-0057.xcresult
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
2025-12-20 06:36:12.316 xcodebuild[5427:26654] Writing error result bundle to /var/folders/sm/xrr7tmqj20s7hrsh1qhfl1d40000gn/T/ResultBundle_2025-20-12_06-36-0012.xcresult
xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.
Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the project file for invalid edits or unresolved source control conflicts.
```

### lint

#### Step: `swiftlint`

```
Linting Swift files at paths HomeCooked/
Error: No lintable files found at paths: 'HomeCooked/'
```

#### Step: `swiftformat`

```
Running SwiftFormat...
(lint mode - no files will be changed.)
SwiftFormat completed in 0.05s.
0/28 files require formatting.
```

## 🔍 Top Errors

- `2025-12-20 06:35:57.100 xcodebuild[17935:78903] Writing error result bundle to /var/folders/sm/xrr7t`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the p`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `2025-12-20 06:36:12.316 xcodebuild[5427:26654] Writing error result bundle to /var/folders/sm/xrr7tm`
- `xcodebuild: error: Unable to read project 'HomeCooked.xcodeproj'.`
- `Reason: The project ‘HomeCooked’ is damaged and cannot be opened due to a parse error. Examine the p`
- `Linting Swift files at paths HomeCooked/`
- `Error: No lintable files found at paths: 'HomeCooked/'`
- `Running SwiftFormat...`
- `(lint mode - no files will be changed.)`
- `SwiftFormat completed in 0.05s.`
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

Full structured results: `.ci/summary.json` in branch `claude/plan-ci-fixes-ygU3O`

---
<!-- ci-feedback -->