# ✅ CI Passed

**Run**: [20401820429](https://github.com/mattsq/minello/actions/runs/20401820429)
**Commit**: `0b88053a`
**Branch**: `claude/resolve-ci-issues-Y9c3O`
**PR**: #21
**Time**: 2025-12-20T23:59:19.877810Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview\ Content
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview Content (in target 'HomeCooked' from project 'HomeCooked')
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
builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview\ Content
/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview Content (in target 'HomeCooked' from project 'HomeCooked')
WriteAuxiliaryFile /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/all-product-headers.yaml (in target 'HomeCooked' from project 'HomeCooked')
Testing failed:
One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeCooked/HomeCooked/Preview Content
Testing cancelled because the build failed.
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
(lint mode - no files will be changed.)
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:241:1: error: (consecutiveSpaces) Replace consecutive spaces with a single space.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:378:1: error: (enumNamespaces) Convert types used for hosting only static members into enums (an empty enum is the canonical way to create a namespace in Swift as it can't be instantiated).
SwiftFormat completed in 0.07s.
Source input did not pass lint check.
```

## 🔍 Top Errors

- `builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCook`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `** BUILD FAILED **`
- `The following build commands failed:`
- `ValidateDevelopmentAssets /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermedia`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `builtin-validate-development-assets --validate YES_ERROR /Users/runner/work/minello/minello/HomeCook`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked.xcodeproj: error: One of the paths in DEVEL`
- `WriteAuxiliaryFile /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noi`
- `Testing failed:`
- `One of the paths in DEVELOPMENT_ASSET_PATHS does not exist: /Users/runner/work/minello/minello/HomeC`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:241:`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:378:`
- `SwiftFormat completed in 0.07s.`
- `Source input did not pass lint check.`

## 📦 Artifacts

The following artifacts may be available:
- `test-results`
- `failed-snapshots`
- `lint-results`
- `build-logs`
- `test-logs`
- `lint-logs`

## 📄 Detailed Results

Full structured results: `.ci/summary.json` in branch `claude/resolve-ci-issues-Y9c3O`

---
<!-- ci-feedback -->