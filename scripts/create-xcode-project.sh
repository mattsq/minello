#!/usr/bin/env bash
# Creates a minimal Xcode project for HomeCooked iOS app
# This script generates the necessary project structure for xcodebuild to work

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$REPO_ROOT/HomeCooked"
PROJECT_NAME="HomeCooked"
BUNDLE_ID="com.homecooked.HomeCooked"

echo "Creating Xcode project structure..."

# Create project directory structure
mkdir -p "$PROJECT_DIR/$PROJECT_NAME.xcodeproj"
mkdir -p "$PROJECT_DIR/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Preview Content"

# Create HomeCookedApp.swift (app entry point)
cat > "$PROJECT_DIR/$PROJECT_NAME/HomeCookedApp.swift" <<'EOF'
import SwiftUI
import SwiftData

@main
struct HomeCookedApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainerFactory.create()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
EOF

# Create ContentView.swift (placeholder main view)
cat > "$PROJECT_DIR/$PROJECT_NAME/ContentView.swift" <<'EOF'
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("HomeCooked")
                .navigationTitle("Boards")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! ModelContainerFactory.createInMemory())
}
EOF

# Create Assets catalog Contents.json
cat > "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/Contents.json" <<'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AppIcon Contents.json
cat > "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" <<'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Generate unique UUIDs for project file (using /dev/urandom since uuidgen might not be available)
gen_uuid() {
    # Disable pipefail for this function to avoid SIGPIPE errors
    (set +o pipefail; cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 32 | head -n 1)
}

APP_TARGET_ID=$(gen_uuid)
FRAMEWORK_BUILDPHASE_ID=$(gen_uuid)
RESOURCES_BUILDPHASE_ID=$(gen_uuid)
SOURCES_BUILDPHASE_ID=$(gen_uuid)
APP_PRODUCT_ID=$(gen_uuid)
MAINGROUP_ID=$(gen_uuid)
PROJECT_ID=$(gen_uuid)
HOMECOOKED_GROUP_ID=$(gen_uuid)
ASSETS_GROUP_ID=$(gen_uuid)
PREVIEW_GROUP_ID=$(gen_uuid)
APP_FILE_ID=$(gen_uuid)
CONTENT_FILE_ID=$(gen_uuid)
ASSETS_FILE_ID=$(gen_uuid)
MODELCONTAINER_FILE_ID=$(gen_uuid)
NATIVE_TARGET_ID=$(gen_uuid)
CONFIG_LIST_ID=$(gen_uuid)
DEBUG_CONFIG_ID=$(gen_uuid)
RELEASE_CONFIG_ID=$(gen_uuid)
PROJECT_CONFIG_LIST_ID=$(gen_uuid)
PROJECT_DEBUG_CONFIG_ID=$(gen_uuid)
PROJECT_RELEASE_CONFIG_ID=$(gen_uuid)

# Add all Swift source files to arrays
PERSISTENCE_DIR="$PROJECT_DIR/Persistence"
APP_DIR="$PROJECT_DIR/App"

# Find all Swift files
SWIFT_FILES=(
    "$PROJECT_DIR/$PROJECT_NAME/HomeCookedApp.swift"
    "$PROJECT_DIR/$PROJECT_NAME/ContentView.swift"
    "$PROJECT_DIR/App/ModelContainerFactory.swift"
)

# Find all Swift files in Persistence directory
if [ -d "$PERSISTENCE_DIR" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find "$PERSISTENCE_DIR" -name "*.swift" -type f -print0)
fi

# Generate file references and build file entries
FILE_REFS=""
BUILD_FILES=""
FILE_IDS=()

for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        FILE_ID=$(gen_uuid)
        BUILDFILE_ID=$(gen_uuid)
        FILE_IDS+=("$FILE_ID")

        REL_PATH="${file#$PROJECT_DIR/}"
        FILE_NAME=$(basename "$file")

        FILE_REFS="$FILE_REFS
                $FILE_ID /* $FILE_NAME */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"$FILE_NAME\"; sourceTree = \"<group>\"; };"

        BUILD_FILES="$BUILD_FILES
                $BUILDFILE_ID /* $FILE_NAME in Sources */ = {isa = PBXBuildFile; fileRef = $FILE_ID /* $FILE_NAME */; };"
    fi
done

# Build the sources list for PBXSourcesBuildPhase
SOURCES_LIST=""
for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        FILE_NAME=$(basename "$file")
        # Find the corresponding build file ID
        BUILDFILE_ID=$(echo "$BUILD_FILES" | grep "$FILE_NAME in Sources" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/')
        if [ -n "$BUILDFILE_ID" ]; then
            SOURCES_LIST="$SOURCES_LIST
                        $BUILDFILE_ID /* $FILE_NAME in Sources */,"
        fi
    fi
done

# Create project.pbxproj
cat > "$PROJECT_DIR/$PROJECT_NAME.xcodeproj/project.pbxproj" <<EOF
// !$*UTF8*$!
{
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 56;
        objects = {

/* Begin PBXBuildFile section */
        $APP_FILE_ID /* HomeCookedApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = $(echo "$FILE_REFS" | grep "HomeCookedApp.swift" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/') /* HomeCookedApp.swift */; };
        $CONTENT_FILE_ID /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $(echo "$FILE_REFS" | grep "ContentView.swift" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/') /* ContentView.swift */; };
        $ASSETS_FILE_ID /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = $ASSETS_GROUP_ID /* Assets.xcassets */; };
$BUILD_FILES
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
        $APP_PRODUCT_ID /* HomeCooked.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HomeCooked.app; sourceTree = BUILT_PRODUCTS_DIR; };
        $ASSETS_GROUP_ID /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; };
$FILE_REFS
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
        $FRAMEWORK_BUILDPHASE_ID /* Frameworks */ = {
                isa = PBXFrameworksBuildPhase;
                buildActionMask = 2147483647;
                files = (
                );
                runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
        $MAINGROUP_ID = {
                isa = PBXGroup;
                children = (
                        $HOMECOOKED_GROUP_ID /* HomeCooked */,
                        $APP_PRODUCT_ID /* HomeCooked.app */,
                );
                sourceTree = \"<group>\";
        };
        $HOMECOOKED_GROUP_ID /* HomeCooked */ = {
                isa = PBXGroup;
                children = (
                        $(echo "$FILE_REFS" | grep "HomeCookedApp.swift" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/') /* HomeCookedApp.swift */,
                        $(echo "$FILE_REFS" | grep "ContentView.swift" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/') /* ContentView.swift */,
                        $(echo "$FILE_REFS" | grep "ModelContainerFactory.swift" | sed 's/.*\([A-F0-9]\{32\}\).*/\1/') /* ModelContainerFactory.swift */,
                        $ASSETS_GROUP_ID /* Assets.xcassets */,
                        $PREVIEW_GROUP_ID /* Preview Content */,
                );
                path = HomeCooked;
                sourceTree = \"<group>\";
        };
        $PREVIEW_GROUP_ID /* Preview Content */ = {
                isa = PBXGroup;
                children = (
                );
                path = \"Preview Content\";
                sourceTree = \"<group>\";
        };
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
        $NATIVE_TARGET_ID /* HomeCooked */ = {
                isa = PBXNativeTarget;
                buildConfigurationList = $CONFIG_LIST_ID /* Build configuration list for PBXNativeTarget "HomeCooked" */;
                buildPhases = (
                        $SOURCES_BUILDPHASE_ID /* Sources */,
                        $FRAMEWORK_BUILDPHASE_ID /* Frameworks */,
                        $RESOURCES_BUILDPHASE_ID /* Resources */,
                );
                buildRules = (
                );
                dependencies = (
                );
                name = HomeCooked;
                productName = HomeCooked;
                productReference = $APP_PRODUCT_ID /* HomeCooked.app */;
                productType = \"com.apple.product-type.application\";
        };
/* End PBXNativeTarget section */

/* Begin PBXProject section */
        $PROJECT_ID /* Project object */ = {
                isa = PBXProject;
                attributes = {
                        BuildIndependentTargetsInParallel = 1;
                        LastSwiftUpdateCheck = 1540;
                        LastUpgradeCheck = 1540;
                };
                buildConfigurationList = $PROJECT_CONFIG_LIST_ID /* Build configuration list for PBXProject "HomeCooked" */;
                compatibilityVersion = \"Xcode 14.0\";
                developmentRegion = en;
                hasScannedForEncodings = 0;
                knownRegions = (
                        en,
                        Base,
                );
                mainGroup = $MAINGROUP_ID;
                productRefGroup = $MAINGROUP_ID;
                projectDirPath = \"\";
                projectRoot = \"\";
                targets = (
                        $NATIVE_TARGET_ID /* HomeCooked */,
                );
        };
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
        $RESOURCES_BUILDPHASE_ID /* Resources */ = {
                isa = PBXResourcesBuildPhase;
                buildActionMask = 2147483647;
                files = (
                        $ASSETS_FILE_ID /* Assets.xcassets in Resources */,
                );
                runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
        $SOURCES_BUILDPHASE_ID /* Sources */ = {
                isa = PBXSourcesBuildPhase;
                buildActionMask = 2147483647;
                files = (
                        $CONTENT_FILE_ID /* ContentView.swift in Sources */,
                        $APP_FILE_ID /* HomeCookedApp.swift in Sources */,
$SOURCES_LIST
                );
                runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
        $DEBUG_CONFIG_ID /* Debug */ = {
                isa = XCBuildConfiguration;
                buildSettings = {
                        ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                        CODE_SIGN_STYLE = Automatic;
                        CURRENT_PROJECT_VERSION = 1;
                        DEVELOPMENT_ASSET_PATHS = \"HomeCooked/Preview\\ Content\";
                        ENABLE_PREVIEWS = YES;
                        GENERATE_INFOPLIST_FILE = YES;
                        INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                        INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                        INFOPLIST_KEY_UISupportedInterfaceOrientations = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
                        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
                        IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                        LD_RUNPATH_SEARCH_PATHS = \"\$(inherited) @executable_path/Frameworks\";
                        MARKETING_VERSION = 1.0;
                        PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;
                        PRODUCT_NAME = \"\$(TARGET_NAME)\";
                        SUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";
                        SUPPORTS_MACCATALYST = NO;
                        SWIFT_EMIT_LOC_STRINGS = YES;
                        SWIFT_VERSION = 5.0;
                        TARGETED_DEVICE_FAMILY = \"1,2\";
                };
                name = Debug;
        };
        $RELEASE_CONFIG_ID /* Release */ = {
                isa = XCBuildConfiguration;
                buildSettings = {
                        ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                        CODE_SIGN_STYLE = Automatic;
                        CURRENT_PROJECT_VERSION = 1;
                        DEVELOPMENT_ASSET_PATHS = \"HomeCooked/Preview\\ Content\";
                        ENABLE_PREVIEWS = YES;
                        GENERATE_INFOPLIST_FILE = YES;
                        INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                        INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                        INFOPLIST_KEY_UISupportedInterfaceOrientations = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
                        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
                        IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                        LD_RUNPATH_SEARCH_PATHS = \"\$(inherited) @executable_path/Frameworks\";
                        MARKETING_VERSION = 1.0;
                        PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;
                        PRODUCT_NAME = \"\$(TARGET_NAME)\";
                        SUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";
                        SUPPORTS_MACCATALYST = NO;
                        SWIFT_EMIT_LOC_STRINGS = YES;
                        SWIFT_VERSION = 5.0;
                        TARGETED_DEVICE_FAMILY = \"1,2\";
                };
                name = Release;
        };
        $PROJECT_DEBUG_CONFIG_ID /* Debug */ = {
                isa = XCBuildConfiguration;
                buildSettings = {
                        ALWAYS_SEARCH_USER_PATHS = NO;
                        ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
                        CLANG_ANALYZER_NONNULL = YES;
                        CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                        CLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
                        CLANG_ENABLE_MODULES = YES;
                        CLANG_ENABLE_OBJC_ARC = YES;
                        CLANG_ENABLE_OBJC_WEAK = YES;
                        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                        CLANG_WARN_BOOL_CONVERSION = YES;
                        CLANG_WARN_COMMA = YES;
                        CLANG_WARN_CONSTANT_CONVERSION = YES;
                        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                        CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                        CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                        CLANG_WARN_EMPTY_BODY = YES;
                        CLANG_WARN_ENUM_CONVERSION = YES;
                        CLANG_WARN_INFINITE_RECURSION = YES;
                        CLANG_WARN_INT_CONVERSION = YES;
                        CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                        CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                        CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                        CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                        CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                        CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                        CLANG_WARN_STRICT_PROTOTYPES = YES;
                        CLANG_WARN_SUSPICIOUS_MOVE = YES;
                        CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                        CLANG_WARN_UNREACHABLE_CODE = YES;
                        CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                        COPY_PHASE_STRIP = NO;
                        DEBUG_INFORMATION_FORMAT = dwarf;
                        ENABLE_STRICT_OBJC_MSGSEND = YES;
                        ENABLE_TESTABILITY = YES;
                        ENABLE_USER_SCRIPT_SANDBOXING = YES;
                        GCC_C_LANGUAGE_STANDARD = gnu17;
                        GCC_DYNAMIC_NO_PIC = NO;
                        GCC_NO_COMMON_BLOCKS = YES;
                        GCC_OPTIMIZATION_LEVEL = 0;
                        GCC_PREPROCESSOR_DEFINITIONS = (
                                \"DEBUG=1\",
                                \"\$(inherited)\",
                        );
                        GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                        GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                        GCC_WARN_UNDECLARED_SELECTOR = YES;
                        GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                        GCC_WARN_UNUSED_FUNCTION = YES;
                        GCC_WARN_UNUSED_VARIABLE = YES;
                        IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                        LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
                        MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                        MTL_FAST_MATH = YES;
                        ONLY_ACTIVE_ARCH = YES;
                        SWIFT_ACTIVE_COMPILATION_CONDITIONS = \"DEBUG \$(inherited)\";
                        SWIFT_OPTIMIZATION_LEVEL = \"-Onone\";
                };
                name = Debug;
        };
        $PROJECT_RELEASE_CONFIG_ID /* Release */ = {
                isa = XCBuildConfiguration;
                buildSettings = {
                        ALWAYS_SEARCH_USER_PATHS = NO;
                        ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
                        CLANG_ANALYZER_NONNULL = YES;
                        CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                        CLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
                        CLANG_ENABLE_MODULES = YES;
                        CLANG_ENABLE_OBJC_ARC = YES;
                        CLANG_ENABLE_OBJC_WEAK = YES;
                        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                        CLANG_WARN_BOOL_CONVERSION = YES;
                        CLANG_WARN_COMMA = YES;
                        CLANG_WARN_CONSTANT_CONVERSION = YES;
                        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                        CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                        CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                        CLANG_WARN_EMPTY_BODY = YES;
                        CLANG_WARN_ENUM_CONVERSION = YES;
                        CLANG_WARN_INFINITE_RECURSION = YES;
                        CLANG_WARN_INT_CONVERSION = YES;
                        CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                        CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                        CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                        CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                        CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                        CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                        CLANG_WARN_STRICT_PROTOTYPES = YES;
                        CLANG_WARN_SUSPICIOUS_MOVE = YES;
                        CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                        CLANG_WARN_UNREACHABLE_CODE = YES;
                        CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                        COPY_PHASE_STRIP = NO;
                        DEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";
                        ENABLE_NS_ASSERTIONS = NO;
                        ENABLE_STRICT_OBJC_MSGSEND = YES;
                        ENABLE_USER_SCRIPT_SANDBOXING = YES;
                        GCC_C_LANGUAGE_STANDARD = gnu17;
                        GCC_NO_COMMON_BLOCKS = YES;
                        GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                        GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                        GCC_WARN_UNDECLARED_SELECTOR = YES;
                        GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                        GCC_WARN_UNUSED_FUNCTION = YES;
                        GCC_WARN_UNUSED_VARIABLE = YES;
                        IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                        LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
                        MTL_ENABLE_DEBUG_INFO = NO;
                        MTL_FAST_MATH = YES;
                        SWIFT_COMPILATION_MODE = wholemodule;
                };
                name = Release;
        };
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
        $CONFIG_LIST_ID /* Build configuration list for PBXNativeTarget "HomeCooked" */ = {
                isa = XCConfigurationList;
                buildConfigurations = (
                        $DEBUG_CONFIG_ID /* Debug */,
                        $RELEASE_CONFIG_ID /* Release */,
                );
                defaultConfigurationIsVisible = 0;
                defaultConfigurationName = Release;
        };
        $PROJECT_CONFIG_LIST_ID /* Build configuration list for PBXProject "HomeCooked" */ = {
                isa = XCConfigurationList;
                buildConfigurations = (
                        $PROJECT_DEBUG_CONFIG_ID /* Debug */,
                        $PROJECT_RELEASE_CONFIG_ID /* Release */,
                );
                defaultConfigurationIsVisible = 0;
                defaultConfigurationName = Release;
        };
/* End XCConfigurationList section */
        };
        rootObject = $PROJECT_ID /* Project object */;
}
EOF

echo "✅ Xcode project created successfully at $PROJECT_DIR/$PROJECT_NAME.xcodeproj"
echo "📦 Created app entry point at $PROJECT_DIR/$PROJECT_NAME/HomeCookedApp.swift"
echo "🎨 Created assets catalog at $PROJECT_DIR/$PROJECT_NAME/Assets.xcassets"
