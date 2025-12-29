# iOS App Crash: CloudKit Initialization Failure

## Problem Summary

The HomeCooked iOS app crashes immediately on launch in the iOS Simulator with:
```
Exception Type:  EXC_BAD_INSTRUCTION (SIGILL)
Termination Reason: SIGNAL 4 Illegal instruction: 4
```

**Crash Location**: `CloudKitSyncClient.swift:42` - `CKContainer.default()`

**Root Cause**: The app attempts to initialize CloudKit without proper entitlements or iCloud configuration, causing a fatal error when `CKContainer.default()` is called.

## Stack Trace Analysis

```
CloudKitSyncClient.init() at line 42 (CloudKitSyncClient.swift:42)
  ↓
AppDependencyContainer.init() at line 33 (AppDependencyContainer.swift:33)
  ↓
AppDependencyContainer.default() at line 47
  ↓
HomeCookedApp.init() at line 11 (HomeCookedApp.swift:11)
```

The crash happens during app initialization, before any UI is displayed.

## Why This Happens

1. **Missing Entitlements**: The app has no `.entitlements` file with CloudKit/iCloud capabilities
2. **Unconditional CloudKit Init**: `CloudKitSyncClient` is created unconditionally when `canImport(CloudKit)` is true (which includes simulator)
3. **No Runtime Check**: The code doesn't check if CloudKit is actually available before calling `CKContainer.default()`
4. **Simulator Limitations**: CloudKit requires a signed app with proper entitlements and an active iCloud account

## Solution Options

### Option 1: Add CloudKit Entitlements (Production-Ready)
**Recommended for production builds**

1. Create `App/HomeCooked.entitlements` with CloudKit capabilities
2. Configure CloudKit container identifier in Apple Developer Portal
3. Update `project.yml` to reference entitlements file
4. Add development team ID for code signing

**Pros**: Full CloudKit functionality, proper production setup
**Cons**: Requires Apple Developer account, more setup complexity

### Option 2: Use Runtime Availability Check (Quick Fix)
**Recommended for development/testing**

Modify `AppDependencyContainer.swift` to check CloudKit availability at runtime before initializing `CloudKitSyncClient`. Fall back to `NoopSyncClient` if unavailable.

**Pros**: Works immediately in simulator, no entitlements needed for development
**Cons**: Silently disables sync in simulator (may mask issues)

### Option 3: Hybrid Approach (Best of Both Worlds)
**RECOMMENDED**

Combine both approaches:
1. Add entitlements for production builds
2. Add runtime check to gracefully handle unavailable CloudKit
3. Use compiler flags to switch sync implementations based on build configuration

## Recommended Implementation Plan

### Phase 1: Immediate Fix (Allow App to Run)
**Goal**: Get the app running in simulator without CloudKit

**Changes to `App/DI/AppDependencyContainer.swift`**:

```swift
init(repositoryProvider: RepositoryProvider) {
    self.repositoryProvider = repositoryProvider

    #if canImport(CloudKit)
    // Check if CloudKit is available before initializing
    // In simulator without entitlements, this will fail safely
    if ProcessInfo.processInfo.environment["DISABLE_CLOUDKIT"] == nil {
        do {
            self.syncClient = CloudKitSyncClient(
                boardsRepo: repositoryProvider.boardsRepository,
                listsRepo: repositoryProvider.listsRepository,
                recipesRepo: repositoryProvider.recipesRepository
            )
        } catch {
            print("CloudKit initialization failed: \(error)")
            print("Falling back to NoopSyncClient")
            self.syncClient = NoopSyncClient()
        }
    } else {
        print("CloudKit disabled via environment variable")
        self.syncClient = NoopSyncClient()
    }
    #else
    self.syncClient = NoopSyncClient()
    #endif
}
```

**Problem**: The initializer can't catch the crash because it happens in CloudKit framework itself, not in Swift code.

**Better Solution**: Delay CloudKit initialization

```swift
init(repositoryProvider: RepositoryProvider) {
    self.repositoryProvider = repositoryProvider

    #if canImport(CloudKit) && !DEBUG
    // Only use CloudKit in release builds
    self.syncClient = CloudKitSyncClient(
        boardsRepo: repositoryProvider.boardsRepository,
        listsRepo: repositoryProvider.listsRepository,
        recipesRepo: repositoryProvider.recipesRepository
    )
    #else
    // Use noop sync for debug builds and non-Apple platforms
    self.syncClient = NoopSyncClient()
    #endif
}
```

**Even Better**: Make sync client lazy and check availability first

### Phase 2: Add Proper Entitlements
**Goal**: Enable CloudKit for production builds

1. **Create entitlements file**: `App/HomeCooked.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.homecooked.app</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)com.homecooked.app</string>
</dict>
</plist>
```

2. **Update `project.yml`** to reference entitlements:

```yaml
targets:
  HomeCooked:
    # ... existing config ...
    settings:
      base:
        # ... existing settings ...
        CODE_SIGN_ENTITLEMENTS: App/HomeCooked.entitlements
        DEVELOPMENT_TEAM: "YOUR_TEAM_ID"  # Add your team ID
```

3. **Configure CloudKit container**:
   - Login to Apple Developer Portal
   - Navigate to Certificates, Identifiers & Profiles
   - Create CloudKit container: `iCloud.com.homecooked.app`
   - Associate with app bundle ID: `com.homecooked.app`

### Phase 3: Refactor Sync Client Architecture
**Goal**: Make sync optional and runtime-configurable

1. **Make sync client optional in AppDependencyContainer**:

```swift
@MainActor
final class AppDependencyContainer: ObservableObject {
    let repositoryProvider: RepositoryProvider
    private(set) var syncClient: (any SyncClient)?

    init(repositoryProvider: RepositoryProvider, enableSync: Bool = true) {
        self.repositoryProvider = repositoryProvider

        if enableSync {
            #if canImport(CloudKit) && !targetEnvironment(simulator)
            // Only enable CloudKit on real devices with proper entitlements
            self.syncClient = CloudKitSyncClient(
                boardsRepo: repositoryProvider.boardsRepository,
                listsRepo: repositoryProvider.listsRepository,
                recipesRepo: repositoryProvider.recipesRepository
            )
            #else
            self.syncClient = NoopSyncClient()
            #endif
        } else {
            self.syncClient = nil
        }
    }
}
```

2. **Update CloudKitSyncClient to fail gracefully**:

Add availability check in init:

```swift
public init(
    containerIdentifier: String? = nil,
    boardsRepo: BoardsRepository,
    listsRepo: ListsRepository,
    recipesRepo: RecipesRepository
) throws {
    // Check CloudKit availability before initializing container
    // This prevents crashes on simulator without entitlements

    self.boardsRepo = boardsRepo
    self.listsRepo = listsRepo
    self.recipesRepo = recipesRepo

    if let identifier = containerIdentifier {
        self.container = CKContainer(identifier: identifier)
    } else {
        self.container = CKContainer.default()
    }

    privateDatabase = container.privateCloudDatabase
    customZoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
}
```

## Immediate Action Items

### Critical (Do First)
1. ✅ **Fix the crash** - Modify `AppDependencyContainer.swift` to use `NoopSyncClient` for DEBUG builds
   - File: `App/DI/AppDependencyContainer.swift`
   - Change: Conditionally compile CloudKit for release builds only

### Important (Do Soon)
2. ⚠️ **Add entitlements** - Create `App/HomeCooked.entitlements` file
3. ⚠️ **Update project.yml** - Reference entitlements file
4. ⚠️ **Document CloudKit setup** - Add instructions to DEVELOPMENT.md

### Nice to Have (Future Improvement)
5. 💡 **Add sync toggle** - Let users enable/disable sync in Settings
6. 💡 **Better error handling** - Show UI message when CloudKit unavailable
7. 💡 **Add CloudKit health check** - Verify entitlements and account status on launch

## Files to Modify

### 1. `App/DI/AppDependencyContainer.swift`
**Location**: Lines 29-40
**Change**: Add DEBUG check to disable CloudKit in debug builds

```swift
#if canImport(CloudKit) && !DEBUG
// Only use CloudKit in release builds
self.syncClient = CloudKitSyncClient(
    boardsRepo: repositoryProvider.boardsRepository,
    listsRepo: repositoryProvider.listsRepository,
    recipesRepo: repositoryProvider.recipesRepository
)
#else
self.syncClient = NoopSyncClient()
#endif
```

### 2. `App/HomeCooked.entitlements` (NEW FILE)
**Action**: Create new file with CloudKit entitlements

### 3. `project.yml`
**Location**: Lines 70-80 (HomeCooked target settings)
**Change**: Add entitlements reference

```yaml
CODE_SIGN_ENTITLEMENTS: App/HomeCooked.entitlements
```

### 4. `DEVELOPMENT.md`
**Action**: Document CloudKit setup requirements

## Testing Plan

1. **Test Fix in Simulator**:
   ```bash
   make test-macos
   xcrun simctl launch 67366ED6-0FC4-4A74-944F-F34992735E39 com.homecooked.app
   ```
   - App should launch without crashing
   - Sync should be disabled (NoopSyncClient)

2. **Test Release Build** (after entitlements added):
   - Build in Release configuration
   - Verify CloudKit initializes correctly
   - Test on real device with iCloud account

3. **Verify Fallback**:
   - Remove entitlements temporarily
   - App should still launch with NoopSyncClient
   - No crashes or fatal errors

## Alternative Quick Fix

If you need the app running immediately without code changes, you can set an environment variable:

```bash
# Launch simulator with CloudKit disabled
DISABLE_CLOUDKIT=1 xcrun simctl launch 67366ED6-0FC4-4A74-944F-F34992735E39 com.homecooked.app
```

This requires modifying the code to check for this environment variable (see Phase 1 alternative solution above).

## Success Criteria

- ✅ App launches successfully in iOS Simulator
- ✅ No crashes on initialization
- ✅ Sync functionality disabled in debug builds (uses NoopSyncClient)
- ✅ CloudKit works in release builds on real devices (after entitlements added)
- ✅ Clear logging when CloudKit is unavailable
- ✅ No breaking changes to existing functionality

## References

- **Crash Log**: Lines 42-43 in CloudKitSyncClient.swift
- **CloudKit Documentation**: https://developer.apple.com/documentation/cloudkit
- **Entitlements Guide**: https://developer.apple.com/documentation/bundleresources/entitlements
- **Similar Issue**: This is a common problem when developing CloudKit apps - see "CloudKit container not found" errors

## Notes

- The project currently has NO entitlements file in the App directory
- The `#if canImport(CloudKit)` check passes in simulator, but CloudKit isn't actually usable
- The crash is in the CloudKit framework, not our code, so try/catch won't help
- Using `#if !DEBUG` is the cleanest solution for development workflow
