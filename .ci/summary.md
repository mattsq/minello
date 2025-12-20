# ✅ CI Passed

**Run**: [20400979228](https://github.com/mattsq/minello/actions/runs/20400979228)
**Commit**: `2cb8f91e`
**Branch**: `claude/resolve-ci-issues-aQiQu`
**PR**: #20
**Time**: 2025-12-20T22:36:33.001165Z

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
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:33:59: error: argument 'column' must precede argument 'sortKey'
let card = Card(title: "Test Card", sortKey: 100, column: column)
~~~~~~~~~~~~~~^~~~~~~~~~~~~~
column: column,
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:91:54: error: argument 'column' must precede argument 'sortKey'
let card = Card(title: "Card", sortKey: 100, column: column)
@__swiftmacro_15HomeCookedTests022PersistenceIntegrationC0C19testCascadingDeleteyyYaKF9PredicatefMf_.swift:2:26: error: cannot convert value of type 'PredicateExpressions.Equal<PredicateExpressions.KeyPath<PredicateExpressions.Variable<Column>, UUID>, PredicateExpressions.KeyPath<PredicateExpressions.Value<Column>, UUID>>' to closure result type 'any StandardPredicateExpression<Bool>'
PredicateExpressions.build_Equal(
~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~
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
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:25:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:26:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:27:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:67:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:68:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:69:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:70:1: error: (wrap) Wrap lines that exceed the specified maximum width.
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
- `/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:33`
- `let card = Card(title: "Test Card", sortKey: 100, column: column)`
- `~~~~~~~~~~~~~~^~~~~~~~~~~~~~`
- `column: column,`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:241:`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:378:`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration`
- `/Users/runner/work/minello/minello/HomeCooked/HomeCooked/Persistence/Migrations/CardSortKeyMigration`

## 📦 Artifacts

The following artifacts may be available:
- `test-results`
- `failed-snapshots`
- `lint-results`
- `build-logs`
- `test-logs`
- `lint-logs`

## 📄 Detailed Results

Full structured results: `.ci/summary.json` in branch `claude/resolve-ci-issues-aQiQu`

---
<!-- ci-feedback -->