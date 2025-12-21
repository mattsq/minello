# ✅ CI Passed

**Run**: [20402895742](https://github.com/mattsq/minello/actions/runs/20402895742)
**Commit**: `d3165270`
**Branch**: `claude/research-build-failures-vYbRs`
**PR**: #23
**Time**: 2025-12-21T01:39:55.190221Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
cd /Users/runner/work/minello/minello/HomeCooked
builtin-validationUtility /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
Touch /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
cd /Users/runner/work/minello/minello/HomeCooked
/usr/bin/touch -c /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
** BUILD SUCCEEDED **
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
^
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:32:13: error: argument 'column' must precede argument 'sortKey'
column: column1
~~~~~~~~~~~~^~~~~~~~~~~~~~~
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:37:13: error: argument 'column' must precede argument 'sortKey'
Testing failed:
Argument 'column' must precede argument 'sortKey'
** TEST FAILED **
The following build commands failed:
SwiftCompile normal x86_64 /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
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
/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:1:1: error: (sortImports) Sort import statements alphabetically.
/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:2:1: error: (sortImports) Sort import statements alphabetically.
SwiftFormat completed in 0.05s.
Source input did not pass lint check.
```

## 🔍 Top Errors

- `cd /Users/runner/work/minello/minello/HomeCooked`
- `builtin-validationUtility /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/D`
- `Touch /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator`
- `cd /Users/runner/work/minello/minello/HomeCooked`
- `/usr/bin/touch -c /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iph`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `^`
- `/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:32:13: error: a`
- `column: column1`
- `~~~~~~~~~~~~^~~~~~~~~~~~~~~`
- `/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:37:13: error: a`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:1:1: error: (sortImports) Sort`
- `/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:2:1: error: (sortImports) Sort`
- `SwiftFormat completed in 0.05s.`
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

Full structured results: `.ci/summary.json` in branch `claude/research-build-failures-vYbRs`

---
<!-- ci-feedback -->