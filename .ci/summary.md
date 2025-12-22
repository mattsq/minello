# ❌ CI Failed (failure)

**Run**: [20421408557](https://github.com/mattsq/minello/actions/runs/20421408557)
**Commit**: `4424a69e`
**Branch**: `claude/fix-ci-cascading-delete`
**PR**: #33
**Time**: 2025-12-22T04:10:47.530137Z

## 📊 Error Statistics

- **Lint Violations**: 96

## Job Results

- ✅ **build**: success
- ❌ **test**: failure
- ✅ **lint**: success (96 errors)

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
2025-12-22 04:07:36.977 appintentsnltrainingprocessor[9382:43172] Parsing options for appintentsnltrainingprocessor
2025-12-22 04:07:36.979 appintentsnltrainingprocessor[9382:43172] No AppShortcuts found - Skipping.
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
2025-12-22 04:07:36.977 appintentsnltrainingprocessor[9382:43172] Parsing options for appintentsnltrainingprocessor
2025-12-22 04:07:36.979 appintentsnltrainingprocessor[9382:43172] No AppShortcuts found - Skipping.
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

**Error Summary:**
- Compilation Errors: 0
- Compilation Warnings: 12

<details>
<summary><b>Compilation Errors (12)</b></summary>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13**
```
warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftEmitModule normal x86_64 Emitting\ module\ for\ HomeCookedTests (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-swiftTaskExecution -- /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -emit-module -experimental-skip-non-inlinable-function-bodies-without-types /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -target x86_64-apple-ios17.0-simulator -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -emit-module-doc-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests.swiftdoc -emit-module-source-info-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests.swiftsourceinfo -emit-objc-header-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests-Swift.h -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests-master-emit-module.dia -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests-master-emit-module.d -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests.swiftmodule -emit-abi-descriptor-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests.abi.json
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13**
```
warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13: warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class PersistenceIntegrationTests: XCTestCase {
            ^
```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13**
```
warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13: warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class PersistenceIntegrationTests: XCTestCase {
            ^

SwiftEmitModule normal arm64 Emitting\ module\ for\ HomeCookedTests (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13**
```
warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftEmitModule normal arm64 Emitting\ module\ for\ HomeCookedTests (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    builtin-swiftTaskExecution -- /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -emit-module -experimental-skip-non-inlinable-function-bodies-without-types /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -target arm64-apple-ios17.0-simulator -Xllvm -aarch64-use-tbi -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -emit-module-doc-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests.swiftdoc -emit-module-source-info-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests.swiftsourceinfo -emit-objc-header-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests-Swift.h -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests-master-emit-module.dia -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests-master-emit-module.d -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests.swiftmodule -emit-abi-descriptor-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests.abi.json
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13**
```
warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13: warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class PersistenceIntegrationTests: XCTestCase {
            ^
```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13**
```
warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^
/Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift:6:13: warning: main actor-isolated class 'PersistenceIntegrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class PersistenceIntegrationTests: XCTestCase {
            ^

SwiftDriverJobDiscovery normal arm64 Compiling ListsRepository.swift, CardSortKeyMigration.swift, Card.swift, Board.swift, ChecklistItem.swift (in target 'HomeCooked' from project 'HomeCooked')

```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13**
```
warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftCompile normal x86_64 /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c -primary-file /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.d -emit-const-values-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.swiftconstvalues -emit-reference-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.swiftdeps -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.dia -target x86_64-apple-ios17.0-simulator -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/BoardsRepositoryTests.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^

SwiftDriverJobDiscovery normal x86_64 Emitting module for HomeCookedTests (in target 'HomeCookedTests' from project 'HomeCooked')

```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13**
```
warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftCompile normal x86_64 /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.d -emit-const-values-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.swiftconstvalues -emit-reference-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.swiftdeps -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.dia -target x86_64-apple-ios17.0-simulator -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/x86_64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/x86_64/CardMigrationTests.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^

SwiftDriverJobDiscovery normal x86_64 Compiling BoardsRepositoryTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')

```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13**
```
warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftCompile normal arm64 /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift -primary-file /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.d -emit-const-values-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.swiftconstvalues -emit-reference-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.swiftdeps -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.dia -target arm64-apple-ios17.0-simulator -Xllvm -aarch64-use-tbi -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/CardMigrationTests.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift:6:13: warning: main actor-isolated class 'CardMigrationTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class CardMigrationTests: XCTestCase {
            ^

SwiftDriverJobDiscovery normal x86_64 Compiling CardMigrationTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')

```
</details>

**/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13**
```
warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
```
<details>
<summary>Context</summary>

```swift
SwiftCompile normal arm64 /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
    /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c -primary-file /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Unit/CardMigrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift -emit-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.d -emit-const-values-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.swiftconstvalues -emit-reference-dependencies-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.swiftdeps -serialize-diagnostics-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.dia -target arm64-apple-ios17.0-simulator -Xllvm -aarch64-use-tbi -enable-objc-interop -sdk /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk -I /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -I /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/lib -F /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks -F /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/Developer/Library/Frameworks -no-color-diagnostics -enable-testing -g -module-cache-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex -profile-generate -profile-coverage-mapping -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -const-gather-protocols-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/HomeCookedTests_const_extract_protocols.json -enable-bare-slash-regex -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/runner/work/minello/minello/HomeCooked/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/runner/work/minello/minello/HomeCooked -resource-dir /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -enable-anonymous-context-mangled-names -Xcc -ivfsstatcache -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/SDKStatCaches.noindex/iphonesimulator17.5-21F77-23950cd4b3f73050108268841b0fa1a8.sdkstatcache -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-generated-files.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-own-target-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-all-target-headers.hmap -Xcc -iquote -Xcc /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/HomeCookedTests-project-headers.hmap -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources-normal/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources/arm64 -Xcc -I/Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/DerivedSources -Xcc -DDEBUG\=1 -module-name HomeCookedTests -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.5 -target-sdk-name iphonesimulator17.5 -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins\#/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /Users/runner/work/minello/minello/HomeCooked/DerivedData/Build/Intermediates.noindex/HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.o -index-unit-output-path /HomeCooked.build/Debug-iphonesimulator/HomeCookedTests.build/Objects-normal/arm64/BoardsRepositoryTests.o -index-store-path /Users/runner/work/minello/minello/HomeCooked/DerivedData/Index.noindex/DataStore -index-system-modules
/Users/runner/work/minello/minello/HomeCooked/Tests/Unit/BoardsRepositoryTests.swift:6:13: warning: main actor-isolated class 'BoardsRepositoryTests' has different actor isolation from nonisolated superclass 'XCTestCase'; this is an error in Swift 6
final class BoardsRepositoryTests: XCTestCase {
            ^

SwiftCompile normal x86_64 Compiling\ PersistenceIntegrationTests.swift /Users/runner/work/minello/minello/HomeCooked/Tests/Integration/PersistenceIntegrationTests.swift (in target 'HomeCookedTests' from project 'HomeCooked')
    cd /Users/runner/work/minello/minello/HomeCooked
```
</details>

_... and 2 more compilation errors_

</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
Test Case '-[HomeCookedTests.BoardsRepositoryTests testFetchAllReturnsAllBoards]' started.
Test Case '-[HomeCookedTests.BoardsRepositoryTests testFetchAllReturnsAllBoards]' passed (0.008 seconds).
Test Case '-[HomeCookedTests.BoardsRepositoryTests testUpdateBoard]' started.
Test Case '-[HomeCookedTests.BoardsRepositoryTests testUpdateBoard]' passed (0.006 seconds).
Test Suite 'BoardsRepositoryTests' failed at 2025-12-22 04:09:55.491.
	 Executed 4 tests, with 1 failure (0 unexpected) in 0.043 (0.044) seconds
Test Suite 'CardMigrationTests' started at 2025-12-22 04:09:55.491.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testMigrationHandlesMultipleColumns]' passed (0.012 seconds).
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' started.
Test Case '-[HomeCookedTests.CardMigrationTests testSortKeyInitializedAscending]' passed (0.008 seconds).
Test Suite 'CardMigrationTests' passed at 2025-12-22 04:09:55.512.
	 Executed 2 tests, with 0 failures (0 unexpected) in 0.021 (0.021) seconds
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 04:09:55.512.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testCascadingDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testCascadingDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 04:09:56.655.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 04:09:56.655.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 04:09:56.655.
Test Case '-[HomeCookedTests.PersistenceIntegrationTests testRoundTripCreateFetchDelete]' started.
Restarting after unexpected exit, crash, or test timeout in PersistenceIntegrationTests.testRoundTripCreateFetchDelete(); summary will include totals from previous launches.
Test Suite 'Selected tests' started at 2025-12-22 04:09:57.945.
Test Suite 'HomeCookedTests.xctest' started at 2025-12-22 04:09:57.945.
Test Suite 'PersistenceIntegrationTests' started at 2025-12-22 04:09:57.946.
Test Suite 'PersistenceIntegrationTests' failed at 2025-12-22 04:09:57.946.
	 Executed 2 tests, with 2 failures (0 unexpected) in 0.000 (0.000) seconds
Test Suite 'HomeCookedTests.xctest' failed at 2025-12-22 04:09:57.946.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.000) seconds
Test Suite 'Selected tests' failed at 2025-12-22 04:09:57.946.
	 Executed 8 tests, with 3 failures (0 unexpected) in 0.000 (0.001) seconds
2025-12-22 04:10:24.348 xcodebuild[1595:8310] [MT] IDETestOperationsObserverDebug: 121.241 elapsed -- Testing started completed.
2025-12-22 04:10:24.349 xcodebuild[1595:8310] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
2025-12-22 04:10:24.349 xcodebuild[1595:8310] [MT] IDETestOperationsObserverDebug: 121.241 sec, +121.241 sec -- end
Test session results, code coverage, and logs:
	/Users/runner/work/minello/minello/HomeCooked/DerivedData/Logs/Test/Test-HomeCooked-2025.12.22_04-07-59-+0000.xcresult
Failing tests:
	BoardsRepositoryTests.testCreateBoardWithColumnsAndCards()
	PersistenceIntegrationTests.testCascadingDelete()
	PersistenceIntegrationTests.testRoundTripCreateFetchDelete()
** TEST FAILED **
Testing started
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

**Error Summary:**
- Lint Errors: 96
- Lint Warnings: 0

<details>
<summary><b>Lint Violations (96)</b></summary>

**/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:1:1**
```
error: (sortImports) Sort import statements alphabetically.
```

**/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift:2:1**
```
error: (sortImports) Sort import statements alphabetically.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardReorderService.swift:87:1**
```
error: (spaceAroundOperators) Add or remove space around operators or delimiters.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:131:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:132:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:133:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:134:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:135:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:136:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:137:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:138:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:139:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:140:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:141:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:142:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:144:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:145:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:146:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:147:1**
```
error: (indent) Indent code in accordance with the scope level.
```

**/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/CardRow.swift:149:1**
```
error: (indent) Indent code in accordance with the scope level.
```

_... and 76 more lint violations_

</details>

<details>
<summary><b>Full Log Tail (Last 50 Lines)</b></summary>

```
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:241:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:242:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:243:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:244:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:245:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:246:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:247:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:248:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:249:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:250:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:251:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:252:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:253:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:254:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:255:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:256:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:257:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:258:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:260:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:261:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:262:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:263:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:265:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:267:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:269:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:270:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:271:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:272:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:273:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:275:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:276:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:277:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:278:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:279:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:280:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:282:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:283:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:284:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:286:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:288:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:289:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:290:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:291:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Features/BoardDetail/ColumnView.swift:292:1: error: (indent) Indent code in accordance with the scope level.
/Users/runner/work/minello/minello/HomeCooked/Tests/UI/BoardDetailSnapshots.swift:89:1: error: (preferKeyPath) Convert trivial map { $0.foo } closures to keyPath-based syntax.
/Users/runner/work/minello/minello/HomeCooked/Tests/UI/BoardDetailSnapshots.swift:232:1: error: (numberFormatting) Use consistent grouping for numeric literals. Groups will be separated by _ delimiters to improve readability. For each numeric type you can specify a group size (the number of digits in each group) and a threshold (the minimum number of digits in a number before grouping is applied).
SwiftFormat completed in 0.12s.
Source input did not pass lint check.
5/25 files require formatting.
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