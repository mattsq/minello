# ❌ CI Failed (cancelled)

**Run**: [20426572830](https://github.com/mattsq/minello/actions/runs/20426572830)
**Commit**: `760dd45e`
**Branch**: `claude/fix-ci-cascading-delete`
**PR**: #33
**Time**: 2025-12-22T08:47:02.643864Z

## Job Results

- ✅ **build**: success
- 🚫 **test**: cancelled
- ✅ **lint**: success

## ❌ Detailed Failures

### build

#### Step: `build`

<details>
<summary><b>Error Excerpt</b></summary>

```
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-swiftStdLibTool --copy --verbose --scan-executable /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Frameworks --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/PlugIns --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/SystemExtensions --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Extensions --platform iphonesimulator --toolchain /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os
Ignoring --strip-bitcode because --sign was not passed
ExtractAppIntentsMetadata (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsmetadataprocessor --output /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app --toolchain-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --module-name HomeCooked --sdk-root /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk --xcode-version 15F31d --platform-family iOS --deployment-target 17.0 --target-triple arm64-apple-ios17.0-simulator --target-triple x86_64-apple-ios17.0-simulator --binary-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked --dependency-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked_dependency_info.dat --dependency-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked_dependency_info.dat --stringsdata-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/ExtractedAppShortcutsMetadata.stringsdata --stringsdata-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ExtractedAppShortcutsMetadata.stringsdata --source-file-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftFileList --source-file-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftFileList --swift-const-vals-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftConstValuesFileList --swift-const-vals-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftConstValuesFileList --compile-time-extraction --deployment-aware-processing
note: Metadata extraction skipped. No AppIntents.framework dependency found. (in target 'HomeCooked' from project 'HomeCooked')
AppIntentsSSUTraining (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsnltrainingprocessor --infoplist-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Info.plist --temp-dir-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/ssu --bundle-id com.homecooked.HomeCooked --product-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app --extracted-metadata-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Metadata.appintents --archive-ssu-assets
2025-12-22 08:43:40.199 appintentsnltrainingprocessor[2584:12492] Parsing options for appintentsnltrainingprocessor
2025-12-22 08:43:40.201 appintentsnltrainingprocessor[2584:12492] No AppShortcuts found - Skipping.
RegisterExecutionPolicyException /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-RegisterExecutionPolicyException /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
Validate /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-validationUtility /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
Touch /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /usr/bin/touch -c /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
** BUILD SUCCEEDED **
```
</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-Swift-Compilation -- /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -module-name HomeCooked -Onone -enforce-exclusivity\=checked @/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftFileList -DDEBUG -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -target arm64-apple-ios17.0-simulator -enable-bare-slash-regex -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -Xfrontend -serialize-debugging-options -enable-testing -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -swift-version 5 -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -emit-localized-strings -emit-localized-strings-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64 -c -j3 -enable-batch-mode -incremental -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -output-file-map /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked-OutputFileMap.json -use-frontend-parseable-output -save-temps -no-color-diagnostics -serialize-diagnostics -emit-dependencies -emit-module -emit-module-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.swiftmodule -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/swift-overrides.hmap -emit-const-values -Xfrontend -const-gather-protocols-file -Xfrontend /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked_const_extract_protocols.json -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/HomeCooked-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources-normal/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/DerivedSources -Xcc -DDEBUG\=1 -emit-objc-header -emit-objc-header-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked-Swift.h -working-directory /Users/runner/work/minello/minello/HomeCooked -experimental-emit-module-separately -disable-cmo
Ld /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/Binary/HomeCooked normal arm64 (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-ios17.0-simulator -isysroot /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -O0 -L/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Debug-iphonesimulator -L/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Debug-iphonesimulator -F/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -filelist /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.LinkFileList -Xlinker -rpath -Xlinker @executable_path/Frameworks -dead_strip -Xlinker -object_path_lto -Xlinker /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -Xlinker -objc_abi_version -Xlinker 2 -fobjc-link-runtime -L/Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator -L/usr/lib/swift -Xlinker -add_ast_path -Xlinker /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.swiftmodule -Xlinker -dependency_info -Xlinker /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked_dependency_info.dat -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/Binary/HomeCooked
CreateUniversalBinary /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked normal arm64\ x86_64 (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/lipo -create /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/Binary/HomeCooked /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/Binary/HomeCooked -output /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked
WriteAuxiliaryFile /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftConstValuesFileList (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    write-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftConstValuesFileList
WriteAuxiliaryFile /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftConstValuesFileList (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    write-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftConstValuesFileList
CopySwiftLibs /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-swiftStdLibTool --copy --verbose --scan-executable /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Frameworks --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/PlugIns --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/SystemExtensions --scan-folder /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Extensions --platform iphonesimulator --toolchain /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os
Ignoring --strip-bitcode because --sign was not passed
ExtractAppIntentsMetadata (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsmetadataprocessor --output /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app --toolchain-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --module-name HomeCooked --sdk-root /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk --xcode-version 15F31d --platform-family iOS --deployment-target 17.0 --target-triple arm64-apple-ios17.0-simulator --target-triple x86_64-apple-ios17.0-simulator --binary-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/HomeCooked --dependency-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked_dependency_info.dat --dependency-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked_dependency_info.dat --stringsdata-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/ExtractedAppShortcutsMetadata.stringsdata --stringsdata-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/ExtractedAppShortcutsMetadata.stringsdata --source-file-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftFileList --source-file-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftFileList --swift-const-vals-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/arm64/HomeCooked.SwiftConstValuesFileList --swift-const-vals-list /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/Objects-normal/x86_64/HomeCooked.SwiftConstValuesFileList --compile-time-extraction --deployment-aware-processing
note: Metadata extraction skipped. No AppIntents.framework dependency found. (in target 'HomeCooked' from project 'HomeCooked')
AppIntentsSSUTraining (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsnltrainingprocessor --infoplist-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Info.plist --temp-dir-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCooked.build/ssu --bundle-id com.homecooked.HomeCooked --product-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app --extracted-metadata-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app/Metadata.appintents --archive-ssu-assets
2025-12-22 08:43:40.199 appintentsnltrainingprocessor[2584:12492] Parsing options for appintentsnltrainingprocessor
2025-12-22 08:43:40.201 appintentsnltrainingprocessor[2584:12492] No AppShortcuts found - Skipping.
RegisterExecutionPolicyException /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-RegisterExecutionPolicyException /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
Validate /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-validationUtility /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
Touch /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app (in target 'HomeCooked' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /usr/bin/touch -c /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/HomeCooked.app
** BUILD SUCCEEDED **
```
</details>

#### Step: `validate-project`

<details>
<summary><b>Error Excerpt</b></summary>

```
HomeCooked/HomeCooked.xcodeproj/project.pbxproj: ASCII text
=== Brace balance check ===
Opening braces:       72
Closing braces:       72
✓ Braces are balanced
=== Project file structure ===
// !UTF8*14459
{
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 56;
        objects = {
/* Begin PBXBuildFile section */
                D9839F67DE5610596C9B2FED /* BoardsRepositoryTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = DB805F64E8178620C45A3C4C /* BoardsRepositoryTests.swift */; };
...
                                F9B623EAE48DD7FC836DC805 /* Debug */,
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
</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
=== Validating Xcode project file ===
File: HomeCooked/HomeCooked.xcodeproj/project.pbxproj
Size:    31993 bytes
Lines:      512
grep: invalid option -- P
usage: grep [-abcdDEFGHhIiJLlMmnOopqRSsUVvwXxZz] [-A num] [-B num] [-C[num]]
	[-e pattern] [-f file] [--binary-files=value] [--color=when]
	[--context[=num]] [--directories=action] [--label] [--line-buffered]
	[--null] [pattern] [file ...]
Lines starting with tabs: 0
=== Checking for corruption patterns ===
✓ Unix line endings (LF)
⚠️  WARNING: Unexpected encoding
HomeCooked/HomeCooked.xcodeproj/project.pbxproj: ASCII text
=== Brace balance check ===
Opening braces:       72
Closing braces:       72
✓ Braces are balanced
=== Project file structure ===
// !UTF8*14459
{
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 56;
        objects = {
/* Begin PBXBuildFile section */
                D9839F67DE5610596C9B2FED /* BoardsRepositoryTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = DB805F64E8178620C45A3C4C /* BoardsRepositoryTests.swift */; };
...
                                F9B623EAE48DD7FC836DC805 /* Debug */,
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
</details>

### test

#### Step: `test`

<details>
<summary><b>Error Excerpt</b></summary>

```
	 Executed 4 tests, with 1 failure (0 unexpected) in 0.065 (0.074) seconds
Test Suite 'CardMigrationTests' started at 2025-12-22 08:46:26.689.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' passed (0.019 seconds).
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' passed (0.007 seconds).
Test Suite 'CardMigrationTests' passed at 2025-12-22 08:46:26.724.
	 Executed 2 tests, with 0 failures (0 unexpected) in 0.026 (0.035) seconds
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:26.724.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testCascadingDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testCascadingDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 08:46:28.375.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 08:46:28.376.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:28.377.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testRoundTripCreateFetchDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testRoundTripCreateFetchDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 08:46:29.556.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 08:46:29.557.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:29.557.
Test Suite 'PersistenceIntegrationTests' failed at 2025-12-22 08:46:29.558.
	 Executed 2 tests, with 2 failures (0 unexpected) in 0.000 (0.001) seconds
Test Suite 'HomeCookedTests.xctest' failed at 2025-12-22 08:46:29.558.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.001) seconds
Test Suite 'Selected tests' failed at 2025-12-22 08:46:29.559.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.003) seconds
```
</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
[BoardsRepository] fetchColumns board=78A522F1-0552-4EC5-B06D-94C24A52A44A fallback matching on UUID
[BoardsRepository] fetchColumns board=78A522F1-0552-4EC5-B06D-94C24A52A44A fallback descriptor by UUID
[BoardsRepository] fetchColumns board=78A522F1-0552-4EC5-B06D-94C24A52A44A matched=0
[BoardsRepository] fetchAll board=78A522F1-0552-4EC5-B06D-94C24A52A44A title=Board 1 columns=0
[BoardsRepository] fetchColumns board=7798985F-32BF-4D48-AF73-47B24DF505AC boardModelID=PersistentIdentifier(id: SwiftData.PersistentIdentifier.ID(url: x-coredata://1E8004A8-C096-413C-AAB5-FF406CA5D0BA/Board/p2), implementation: SwiftData.PersistentIdentifierImplementation) fetched=0
[BoardsRepository] fetchColumns board=7798985F-32BF-4D48-AF73-47B24DF505AC fallback matching on UUID
[BoardsRepository] fetchColumns board=7798985F-32BF-4D48-AF73-47B24DF505AC fallback descriptor by UUID
[BoardsRepository] fetchColumns board=7798985F-32BF-4D48-AF73-47B24DF505AC matched=0
[BoardsRepository] fetchAll board=7798985F-32BF-4D48-AF73-47B24DF505AC title=Board 2 columns=0
Test Case '-[HomeCookedTests.BoardsRepositoryTests testFetchAllReturnsAllBoards]' passed (0.017 seconds).
Test Case '-[HomeCookedTests.BoardsRepositoryTests testUpdateBoard]' started.
[BoardsRepository] create(board:) board=DD057269-F843-43AB-AFE6-1C87A438BC22 title=Original Title columns=0
[BoardsRepository] post-create totalColumns=0
[BoardsRepository] fetchColumns board=DD057269-F843-43AB-AFE6-1C87A438BC22 boardModelID=PersistentIdentifier(id: SwiftData.PersistentIdentifier.ID(url: x-coredata://B1697104-E982-4715-A7CF-B016E0DD999C/Board/p1), implementation: SwiftData.PersistentIdentifierImplementation) fetched=0
[BoardsRepository] fetchColumns board=DD057269-F843-43AB-AFE6-1C87A438BC22 fallback matching on UUID
[BoardsRepository] fetchColumns board=DD057269-F843-43AB-AFE6-1C87A438BC22 fallback descriptor by UUID
[BoardsRepository] fetchColumns board=DD057269-F843-43AB-AFE6-1C87A438BC22 matched=0
[BoardsRepository] fetch(id:) board=DD057269-F843-43AB-AFE6-1C87A438BC22 title=Updated Title columns=0
Test Case '-[HomeCookedTests.BoardsRepositoryTests testUpdateBoard]' passed (0.008 seconds).
Test Suite 'BoardsRepositoryTests' failed at 2025-12-22 08:46:26.689.
	 Executed 4 tests, with 1 failure (0 unexpected) in 0.065 (0.074) seconds
Test Suite 'CardMigrationTests' started at 2025-12-22 08:46:26.689.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' passed (0.019 seconds).
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' passed (0.007 seconds).
Test Suite 'CardMigrationTests' passed at 2025-12-22 08:46:26.724.
	 Executed 2 tests, with 0 failures (0 unexpected) in 0.026 (0.035) seconds
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:26.724.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testCascadingDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testCascadingDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 08:46:28.375.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 08:46:28.376.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:28.377.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testRoundTripCreateFetchDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testRoundTripCreateFetchDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 08:46:29.556.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 08:46:29.557.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 08:46:29.557.
Test Suite 'PersistenceIntegrationTests' failed at 2025-12-22 08:46:29.558.
	 Executed 2 tests, with 2 failures (0 unexpected) in 0.000 (0.001) seconds
Test Suite 'HomeCookedTests.xctest' failed at 2025-12-22 08:46:29.558.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.001) seconds
Test Suite 'Selected tests' failed at 2025-12-22 08:46:29.559.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.003) seconds
```
</details>

### lint

#### Step: `swiftlint`

<details>
<summary><b>Error Excerpt</b></summary>

```
Linting Swift files in current working directory
Error: No lintable files found at paths: ''
```
</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
Linting Swift files in current working directory
Error: No lintable files found at paths: ''
```
</details>

#### Step: `swiftformat`

<details>
<summary><b>Error Excerpt</b></summary>

```
Running SwiftFormat...
(lint mode - no files will be changed.)
SwiftFormat completed in 0.22s.
0/25 files require formatting.
```
</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
Running SwiftFormat...
(lint mode - no files will be changed.)
SwiftFormat completed in 0.22s.
0/25 files require formatting.
```
</details>

## 📦 Artifacts

The following artifacts may be available for download:
- `test-results` - Available in GitHub Actions artifacts
- `failed-snapshots` - Available in GitHub Actions artifacts
- `lint-results` - Available in GitHub Actions artifacts
- `build-logs` - Available in GitHub Actions artifacts
- `test-logs` - Available in GitHub Actions artifacts
- `lint-logs` - Available in GitHub Actions artifacts

## 📄 Detailed Results

Full structured results available at: `.ci/summary.json` in branch `claude/fix-ci-cascading-delete`

### For Agents

To review failures programmatically:
```bash
# Read the JSON summary
cat .ci/summary.json | jq '.jobs[] | select(.conclusion == "failure")'

# Check specific error types
cat .ci/summary.json | jq '.jobs[].failed_steps[].compilation_errors[]'
cat .ci/summary.json | jq '.jobs[].failed_steps[].test_failures[]'
cat .ci/summary.json | jq '.jobs[].failed_steps[].lint_violations[]'
```

---
<!-- ci-feedback -->