.PHONY: help preflight test-linux test-macos lint import-sample backup-sample clean

# Default target
help:
	@echo "HomeCooked - Available targets:"
	@echo ""
	@echo "  make preflight        Run preflight checks (toolchain, build, skeleton)"
	@echo "  make test-linux       Build and test all Linux-compatible targets"
	@echo "  make test-macos       Build and test iOS app + UI tests (macOS only)"
	@echo "  make lint             Run swiftformat + swiftlint"
	@echo "  make import-sample    Import sample Trello data"
	@echo "  make backup-sample    Create sample backup"
	@echo "  make clean            Clean build artifacts"
	@echo ""

# Preflight checks - verify toolchains and generate skeleton if needed
preflight:
	@./scripts/preflight.sh $(ARGS)

# Linux tests - SwiftPM build and test
test-linux:
	@echo "Building and testing Linux targets..."
	swift build
	swift test --parallel

# macOS tests - Xcode build and test (requires macOS)
test-macos:
	@echo "Building and testing iOS app..."
	@if [ ! -f "HomeCooked.xcodeproj/project.pbxproj" ]; then \
		echo "Error: HomeCooked.xcodeproj not found."; \
		echo "The Xcode project should be committed to the repository."; \
		exit 1; \
	fi
	xcodebuild -project HomeCooked.xcodeproj \
		-scheme HomeCooked \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		build test

# Linting - format and lint check
lint:
	@echo "Running swiftformat..."
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat --lint .; \
	else \
		echo "swiftformat not installed. Install with: brew install swiftformat"; \
		exit 1; \
	fi
	@echo "Running swiftlint..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
	else \
		echo "swiftlint not installed. Install with: brew install swiftlint"; \
		exit 1; \
	fi

# Import sample Trello data
import-sample:
	@echo "Importing sample Trello data..."
	@if [ -f "Tests/Fixtures/trello_minimal.json" ]; then \
		swift run hc-import Tests/Fixtures/trello_minimal.json --db /tmp/homecooked_sample.db; \
	else \
		echo "Sample fixture not found: Tests/Fixtures/trello_minimal.json"; \
		echo "This will be available after implementing ticket #4"; \
	fi

# Create sample backup
backup-sample:
	@echo "Creating sample backup..."
	@if [ -f "/tmp/homecooked_sample.db" ]; then \
		swift run hc-backup --db /tmp/homecooked_sample.db --output /tmp/homecooked_backup.json; \
	else \
		echo "Sample database not found. Run 'make import-sample' first."; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf .build
	rm -rf *.xcodeproj
	rm -rf .swiftpm
	@if [ -d "DerivedData" ]; then rm -rf DerivedData; fi
	@echo "Clean complete"
