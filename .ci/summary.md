# ✅ CI Passed

**Run**: [20391975339](https://github.com/mattsq/minello/actions/runs/20391975339)
**Commit**: `9145f9c3`
**Branch**: `claude/resolve-ci-issues-uj6Op`
**PR**: #15
**Time**: 2025-12-20T08:47:37.818597Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview /Users/runner/work/minello/minello/HomeCooked/Content
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview (in target 'HomeCooked' from project 'HomeCooked')
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/Content (in target 'HomeCooked' from project 'HomeCooked')
** BUILD FAILED **
The following build commands failed:
ValidateDevelopmentAssets /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build (in target 'HomeCooked' from project 'HomeCooked')
(1 failure)
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
builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview /Users/runner/work/minello/minello/HomeCooked/Content
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview (in target 'HomeCooked' from project 'HomeCooked')
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/Content (in target 'HomeCooked' from project 'HomeCooked')
Testing failed:
One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview
One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/Content
** TEST FAILED **
The following build commands failed:
ValidateDevelopmentAssets /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build (in target 'HomeCooked' from project 'HomeCooked')
(1 failure)
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
SwiftFormat completed in 0.07s.
0/28 files require formatting.
```

## 🔍 Top Errors

- `builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCook`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `** BUILD FAILED **`
- `The following build commands failed:`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCook`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `Testing failed:`
- `One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeC`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `Running SwiftFormat...`
- `(lint mode - no files will be changed.)`
- `SwiftFormat completed in 0.07s.`
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

Full structured results: `.ci/summary.json` in branch `claude/resolve-ci-issues-uj6Op`

---
<!-- ci-feedback -->