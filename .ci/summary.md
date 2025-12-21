# ✅ CI Passed

**Run**: [20403315049](https://github.com/mattsq/minello/actions/runs/20403315049)
**Commit**: `87d0bb92`
**Branch**: `claude/plan-test-fixes-tHHMf`
**PR**: #24
**Time**: 2025-12-21T02:23:13.531572Z

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
** TEST FAILED **
Testing started
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
SwiftFormat completed in 0.06s.
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
- `** TEST FAILED **`
- `Testing started`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:1:1: error: (sortImports) Sort`
- `/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:2:1: error: (sortImports) Sort`
- `SwiftFormat completed in 0.06s.`
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

Full structured results: `.ci/summary.json` in branch `claude/plan-test-fixes-tHHMf`

---
<!-- ci-feedback -->