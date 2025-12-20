# ✅ CI Passed

**Run**: [20400779452](https://github.com/mattsq/minello/actions/runs/20400779452)
**Commit**: `85556d38`
**Branch**: `claude/resolve-ci-issues-9w09a`
**PR**: #19
**Time**: 2025-12-20T22:17:18.656078Z

## Job Results

- ✅ **build**: success
- ✅ **test**: success
- ✅ **lint**: success

## ❌ Failures

### build

#### Step: `build`

```
/Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c -primary-file /Users/runner/work/minello/minello/HomeCooked/HomeCooked/HomeCookedApp.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/HomeCooked/ContentView.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/RecipesRepository.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/BoardsRepository.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/ListsRepository.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Card.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Board.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/ChecklistItem.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Column.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/PersonalList.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Recipe.swift /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources/GeneratedAssetSymbols.swift -supplementary-output-file-map /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/supplementaryOutputs-5 -emit-localized-strings -emit-localized-strings-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64 -target x86_64-apple-ios17.0-simulator -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources-normal/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCooked -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCookedApp.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ContentView.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ModelContainerFactory.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/RecipesRepository.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/BoardsRepository.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCookedApp.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ContentView.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ModelContainerFactory.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/RecipesRepository.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/BoardsRepository.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:59: error: cannot convert value of type 'U?' to expected argument type 'ModelConfiguration.CloudKitDatabase'
cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) }
^
as! ModelConfiguration.CloudKitDatabase
/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:66: error: cannot infer contextual base in reference to member 'private'
~^~~~~~~
** BUILD FAILED **
The following build commands failed:
SwiftCompile normal x86_64 Compiling\ HomeCookedApp.swift,\ ContentView.swift,\ ModelContainerFactory.swift,\ RecipesRepository.swift,\ BoardsRepository.swift /Users/runner/work/minello/minello/HomeCooked/HomeCooked/HomeCookedApp.swift /Users/runner/work/minello/minello/HomeCooked/HomeCooked/ContentView.swift /Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/RecipesRepository.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/BoardsRepository.swift (in target 'HomeCooked' from project 'HomeCooked')
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
/Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c -primary-file /Users/runner/work/minello/minello/HomeCooked/HomeCooked/HomeCookedApp.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/HomeCooked/ContentView.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/RecipesRepository.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/BoardsRepository.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Repositories/ListsRepository.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Card.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Board.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/ChecklistItem.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Column.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/PersonalList.swift /Users/runner/work/minello/minello/HomeCooked/Persistence/Models/Recipe.swift /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources/GeneratedAssetSymbols.swift -supplementary-output-file-map /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/supplementaryOutputs-1 -emit-localized-strings -emit-localized-strings-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64 -target x86_64-apple-ios17.0-simulator -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources-normal/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCooked -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCookedApp.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ContentView.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ModelContainerFactory.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/RecipesRepository.o -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/BoardsRepository.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCookedApp.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ContentView.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ModelContainerFactory.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/RecipesRepository.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/BoardsRepository.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:59: error: cannot convert value of type 'U?' to expected argument type 'ModelConfiguration.CloudKitDatabase'
cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) }
^
as! ModelConfiguration.CloudKitDatabase
/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:66: error: cannot infer contextual base in reference to member 'private'
~^~~~~~~
Testing failed:
Cannot convert value of type 'U?' to expected argument type 'ModelConfiguration.CloudKitDatabase'
Cannot infer contextual base in reference to member 'private'
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
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:25:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:26:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:27:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:67:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:68:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:69:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:70:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:93:1: error: (wrap) Wrap lines that exceed the specified maximum width.
/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:94:1: error: (wrap) Wrap lines that exceed the specified maximum width.
```

## 🔍 Top Errors

- `/Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-fr`
- `/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:59: error: cannot c`
- `cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) }`
- `^`
- `as! ModelConfiguration.CloudKitDatabase`
- `9FE81F10FC0F5C68CD205C09 /* Release */,`
- `);`
- `defaultConfigurationIsVisible = 0;`
- `defaultConfigurationName = Release;`
- `};`
- `/Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-fr`
- `/Users/runner/work/minello/minello/HomeCooked/App/ModelContainerFactory.swift:22:59: error: cannot c`
- `cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) }`
- `^`
- `as! ModelConfiguration.CloudKitDatabase`
- `Linting Swift files in current working directory`
- `Error: No lintable files found at paths: ''`
- `(lint mode - no files will be changed.)`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:25:1`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:26:1`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:27:1`
- `/Users/runner/work/minello/minello/HomeCooked/Persistence/Migrations/CardSortKeyMigration.swift:67:1`

## 📦 Artifacts

The following artifacts may be available:
- `test-results`
- `failed-snapshots`
- `lint-results`
- `build-logs`
- `test-logs`
- `lint-logs`

## 📄 Detailed Results

Full structured results: `.ci/summary.json` in branch `claude/resolve-ci-issues-9w09a`

---
<!-- ci-feedback -->