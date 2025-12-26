#!/usr/bin/env bash
set -euo pipefail

# HomeCooked Preflight Script
# Verifies toolchains, builds, and optionally auto-generates missing iOS app skeleton

# Parse arguments
AUTOFIX=false
for arg in "$@"; do
    if [[ "$arg" == "--autofix" ]]; then
        AUTOFIX=true
    fi
done

# Determine platform
OS_TYPE="$(uname -s)"
IS_MACOS=false
if [[ "$OS_TYPE" == "Darwin" ]]; then
    IS_MACOS=true
fi

# Track failures
FAILURES=()

# Colors for output (if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

echo "🚀 HomeCooked Preflight Check"
echo "Platform: $OS_TYPE"
echo ""

# Function to report check results
check() {
    local name="$1"
    local status="$2"
    if [[ "$status" == "ok" ]]; then
        echo -e "${GREEN}✓${NC} $name"
    elif [[ "$status" == "skip" ]]; then
        echo -e "${YELLOW}⊘${NC} $name (skipped)"
    else
        echo -e "${RED}✗${NC} $name"
        FAILURES+=("$name")
    fi
}

# 1. Check Swift version
echo "Checking Swift toolchain..."
EXPECTED_SWIFT_VERSION=""
if [[ -f ".swift-version" ]]; then
    EXPECTED_SWIFT_VERSION=$(cat .swift-version | tr -d '\n\r ')
fi

if command -v swift >/dev/null 2>&1; then
    SWIFT_VERSION=$(swift --version 2>&1 | head -n1)
    echo "  Found: $SWIFT_VERSION"
    if [[ -n "$EXPECTED_SWIFT_VERSION" ]]; then
        if echo "$SWIFT_VERSION" | grep -q "$EXPECTED_SWIFT_VERSION"; then
            check "Swift version ($EXPECTED_SWIFT_VERSION)" "ok"
        else
            check "Swift version ($EXPECTED_SWIFT_VERSION)" "fail"
            echo "  Expected version $EXPECTED_SWIFT_VERSION, but found: $SWIFT_VERSION"
        fi
    else
        check "Swift available" "ok"
    fi
else
    check "Swift toolchain" "fail"
    echo "  Swift not found in PATH"
fi

# 2. Check Package.swift exists
echo ""
echo "Checking Swift package structure..."
if [[ -f "Package.swift" ]]; then
    check "Package.swift exists" "ok"
else
    check "Package.swift exists" "fail"
    echo "  Package.swift not found in repository root"
fi

# 3. Auto-generate iOS app skeleton if missing
echo ""
echo "Checking iOS app skeleton..."
APP_DIR="App"
NEEDS_SKELETON=false

if [[ ! -f "$APP_DIR/HomeCookedApp.swift" ]]; then
    NEEDS_SKELETON=true
fi

if $NEEDS_SKELETON; then
    if $AUTOFIX; then
        echo "  Auto-generating iOS app skeleton..."
        mkdir -p "$APP_DIR/UI"
        mkdir -p "$APP_DIR/Resources"

        # Generate HomeCookedApp.swift
        cat > "$APP_DIR/HomeCookedApp.swift" <<'SWIFT'
import SwiftUI

@main
struct HomeCookedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
SWIFT

        # Generate ContentView.swift
        cat > "$APP_DIR/UI/ContentView.swift" <<'SWIFT'
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("HomeCooked")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ContentView()
}
SWIFT

        # Generate Info.plist placeholder
        cat > "$APP_DIR/Info.plist" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>HomeCooked</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
XML

        # Generate Assets.xcassets structure
        mkdir -p "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset"
        cat > "$APP_DIR/Resources/Assets.xcassets/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

        cat > "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" <<'JSON'
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
JSON

        check "iOS app skeleton generated" "ok"
    else
        check "iOS app skeleton exists" "fail"
        echo "  Run with --autofix to generate skeleton automatically"
    fi
else
    check "iOS app skeleton exists" "ok"
fi

# 4. Verify Package targets (basic check)
echo ""
echo "Verifying Package targets..."
if [[ -f "Package.swift" ]]; then
    # Check that Package.swift contains expected target names
    REQUIRED_TARGETS=("Domain" "UseCases" "PersistenceInterfaces")
    ALL_FOUND=true
    for target in "${REQUIRED_TARGETS[@]}"; do
        if grep -q "\"$target\"" Package.swift; then
            echo "  ✓ Target: $target"
        else
            echo "  ✗ Target: $target (missing)"
            ALL_FOUND=false
        fi
    done

    if $ALL_FOUND; then
        check "Required Package targets present" "ok"
    else
        check "Required Package targets present" "fail"
    fi
else
    check "Package targets verification" "skip"
fi

# 5. Try to build with SwiftPM (skip if targets don't exist yet)
echo ""
echo "Testing SwiftPM build..."
if [[ -d "Packages" ]] || [[ -d "Sources" ]]; then
    if swift build 2>&1 | tee /tmp/preflight_build.log; then
        check "SwiftPM build" "ok"
    else
        # Check if it's just missing sources (acceptable for skeleton)
        if grep -q "no targets found" /tmp/preflight_build.log || grep -q "no buildable targets" /tmp/preflight_build.log; then
            check "SwiftPM build" "skip"
            echo "  No source files yet (expected for fresh setup)"
        else
            check "SwiftPM build" "fail"
            echo "  See /tmp/preflight_build.log for details"
        fi
    fi
else
    check "SwiftPM build" "skip"
    echo "  No Packages/ or Sources/ directory yet"
fi

# 6. macOS-specific checks
if $IS_MACOS; then
    echo ""
    echo "Checking Xcode (macOS only)..."

    # Check Xcode version
    EXPECTED_XCODE_VERSION=""
    if [[ -f ".xcode-version" ]]; then
        EXPECTED_XCODE_VERSION=$(cat .xcode-version | tr -d '\n\r ')
    fi

    if command -v xcodebuild >/dev/null 2>&1; then
        # Use || true to handle SIGPIPE from head -n1
        XCODE_VERSION=$(xcodebuild -version 2>&1 | head -n1 | awk '{print $2}' || true)
        echo "  Found: Xcode $XCODE_VERSION"

        if [[ -n "$EXPECTED_XCODE_VERSION" ]]; then
            if [[ "$XCODE_VERSION" == "$EXPECTED_XCODE_VERSION"* ]]; then
                check "Xcode version ($EXPECTED_XCODE_VERSION)" "ok"
            else
                check "Xcode version ($EXPECTED_XCODE_VERSION)" "fail"
                echo "  Expected version $EXPECTED_XCODE_VERSION, but found: $XCODE_VERSION"
            fi
        else
            check "Xcode available" "ok"
        fi

        # Try xcodebuild -list if workspace or project exists
        if [[ -f "HomeCooked.xcworkspace" ]] || [[ -f "HomeCooked.xcodeproj" ]]; then
            echo ""
            echo "Checking Xcode workspace/project..."
            if [[ -f "HomeCooked.xcworkspace" ]]; then
                if xcodebuild -list -workspace HomeCooked.xcworkspace >/tmp/preflight_xcode_list.log 2>&1; then
                    check "xcodebuild -list (workspace)" "ok"
                else
                    check "xcodebuild -list (workspace)" "fail"
                    echo "  See /tmp/preflight_xcode_list.log for details"
                fi
            elif [[ -f "HomeCooked.xcodeproj" ]]; then
                if xcodebuild -list -project HomeCooked.xcodeproj >/tmp/preflight_xcode_list.log 2>&1; then
                    check "xcodebuild -list (project)" "ok"
                else
                    check "xcodebuild -list (project)" "fail"
                    echo "  See /tmp/preflight_xcode_list.log for details"
                fi
            fi
        else
            echo "  No Xcode workspace/project found (expected for fresh setup)"
        fi
    else
        check "Xcode" "fail"
        echo "  xcodebuild not found. Install Xcode from the App Store."
    fi
else
    echo ""
    echo "Skipping Xcode checks (not on macOS)"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ ${#FAILURES[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ Preflight passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Preflight failed${NC}"
    echo ""
    echo "Failed checks:"
    for failure in "${FAILURES[@]}"; do
        echo "  - $failure"
    done
    echo ""
    if ! $AUTOFIX; then
        echo "Tip: Run with --autofix to automatically fix some issues"
    fi
    exit 1
fi
