#!/usr/bin/env bash
# Codex Web Agent Setup Script for HomeCooked iOS Project
# This script prepares the environment for Codex Web agents to work on this repository.
# Since this is an iOS project, we focus on validation tools and task tracking rather than building.

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
BIN_DIR="$CODEX_HOME/bin"
ENV_FILE="$CODEX_HOME/env.sh"
GO_VERSION="1.22.0"
BEADS_VERSION="v0.3.0"

# Core dependencies needed for this project
REQUIRED_TOOLS=(
    git
    curl
    jq
)

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[codex-setup]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[codex-setup]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[codex-setup]${NC} $*" >&2
}

run_sudo() {
    if [[ $EUID -ne 0 ]]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Detect OS and package manager
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
    else
        log_error "Unable to detect OS"
        exit 1
    fi
    log_info "Detected OS: $OS $OS_VERSION"
}

# Install core system dependencies
ensure_system_packages() {
    log_info "Installing system dependencies..."

    if command -v apt-get >/dev/null 2>&1; then
        run_sudo apt-get update -y
        run_sudo apt-get install -y --no-install-recommends git curl jq sqlite3
    elif command -v yum >/dev/null 2>&1; then
        run_sudo yum install -y git curl jq sqlite
    elif command -v brew >/dev/null 2>&1; then
        brew install git curl jq sqlite3
    else
        log_warn "No supported package manager found. Ensure git, curl, jq, and sqlite3 are installed manually."
    fi
}

# Install Go for beads dependency
install_go() {
    if command -v go >/dev/null 2>&1; then
        local current_version=$(go version | awk '{print $3}' | sed 's/go//')
        log_info "Go already installed: $current_version"
        return
    fi

    log_info "Installing Go ${GO_VERSION}..."
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')

    # Map architecture names
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $arch"; exit 1 ;;
    esac

    local go_archive="go${GO_VERSION}.${os}-${arch}.tar.gz"
    local go_url="https://go.dev/dl/${go_archive}"
    local tmp_dir=$(mktemp -d)

    log_info "Downloading Go from ${go_url}..."
    curl -fsSL "$go_url" -o "$tmp_dir/$go_archive"

    run_sudo rm -rf /usr/local/go
    run_sudo tar -C /usr/local -xzf "$tmp_dir/$go_archive"
    rm -rf "$tmp_dir"

    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
}

# Install beads task tracker
install_beads() {
    local beads_path="$HOME/go/bin/bd"

    if [[ -x "$beads_path" ]]; then
        log_info "Beads already installed at $beads_path"
        return
    fi

    log_info "Installing beads task tracker..."

    # Ensure Go is in PATH
    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"

    # Install beads via go install
    go install github.com/beadsland/beads/cmd/bd@latest || {
        log_error "Failed to install beads. Ensure Go is properly installed."
        exit 1
    }

    if [[ -x "$beads_path" ]]; then
        log_info "Beads installed successfully at $beads_path"
    else
        log_error "Beads installation verification failed"
        exit 1
    fi
}

# Initialize beads if needed
init_beads() {
    local beads_path="$HOME/go/bin/bd"

    if [[ ! -d "$REPO_ROOT/.beads" ]]; then
        log_info "Initializing beads in repository..."
        cd "$REPO_ROOT"
        "$beads_path" init || log_warn "Beads init failed or already initialized"
    fi

    # Verify beads is working
    cd "$REPO_ROOT"
    "$beads_path" list --status open >/dev/null 2>&1 || log_warn "Beads verification failed"
}

# Create validation script for project structure
create_validation_script() {
    mkdir -p "$BIN_DIR"
    local validator="$BIN_DIR/validate-homecooked"

    cat >"$validator" <<'VALIDATOR_EOF'
#!/usr/bin/env bash
# Validates HomeCooked project structure and requirements

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ERRORS=0

check_file() {
    if [[ ! -f "$1" ]]; then
        echo "❌ Missing required file: $1"
        ((ERRORS++))
    else
        echo "✓ Found: $1"
    fi
}

check_dir() {
    if [[ ! -d "$1" ]]; then
        echo "❌ Missing required directory: $1"
        ((ERRORS++))
    else
        echo "✓ Found: $1"
    fi
}

echo "Validating HomeCooked project structure..."
echo "Repository root: $REPO_ROOT"
echo ""

# Check required documentation
check_file "$REPO_ROOT/CLAUDE.md"
check_file "$REPO_ROOT/AGENTS.md"
check_file "$REPO_ROOT/README.md"

# Check beads setup
check_dir "$REPO_ROOT/.beads"
check_file "$REPO_ROOT/.beads/issues.jsonl"

# Check for Git
if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Not a git repository"
    ((ERRORS++))
else
    echo "✓ Git repository initialized"
fi

# Check for beads binary
if ! command -v "$HOME/go/bin/bd" >/dev/null 2>&1; then
    echo "❌ Beads (bd) not found at $HOME/go/bin/bd"
    ((ERRORS++))
else
    echo "✓ Beads binary available"
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ All validation checks passed!"
    exit 0
else
    echo "❌ Validation failed with $ERRORS error(s)"
    exit 1
fi
VALIDATOR_EOF

    chmod +x "$validator"
    log_info "Created validation script at $validator"
}

# Write environment configuration
write_env_file() {
    mkdir -p "$CODEX_HOME"

    cat >"$ENV_FILE" <<'ENV_EOF'
# shellcheck shell=bash
# Codex Web Agent Environment for HomeCooked Project

export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
export GOPATH="$HOME/go"
export BEADS_BIN="$HOME/go/bin/bd"

# Project-specific variables
export HOMECOOKED_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export HOMECOOKED_BEADS="$HOMECOOKED_ROOT/.beads"

# Helper aliases for common tasks
alias bd="$HOME/go/bin/bd"
alias validate-project="$HOME/.codex/bin/validate-homecooked"

# Display current project info
echo "HomeCooked Development Environment"
echo "  Root: $HOMECOOKED_ROOT"
echo "  Beads: $BEADS_BIN"
echo ""
echo "Commands:"
echo "  bd ready        - Show ready tasks"
echo "  bd list         - List all issues"
echo "  validate-project - Validate project structure"
ENV_EOF

    chmod +x "$ENV_FILE"
    log_info "Created environment file at $ENV_FILE"
}

# Run validation to ensure everything is set up correctly
run_validation() {
    log_info "Running project validation..."

    if [[ -x "$BIN_DIR/validate-homecooked" ]]; then
        "$BIN_DIR/validate-homecooked" || log_warn "Validation found issues (this is normal for initial setup)"
    fi
}

# Print setup summary
print_summary() {
    cat <<SUMMARY

╔════════════════════════════════════════════════════════════════╗
║              Codex Web Setup Complete                          ║
╚════════════════════════════════════════════════════════════════╝

Environment prepared for HomeCooked iOS project.

📍 Repository: $REPO_ROOT
🔧 Tools Directory: $BIN_DIR
📝 Beads Binary: $HOME/go/bin/bd
✅ Validator: $BIN_DIR/validate-homecooked

To activate this environment:
  source "$ENV_FILE"

Quick Start:
  1. Check ready tasks: $HOME/go/bin/bd ready
  2. Validate project: $BIN_DIR/validate-homecooked
  3. Read instructions: cat $REPO_ROOT/CLAUDE.md

Note: This is an iOS/SwiftUI project. Actual building requires macOS/Xcode.
      This setup provides task tracking and validation for Codex Web agents.

SUMMARY
}

# Main setup flow
main() {
    log_info "Starting Codex Web setup for HomeCooked project..."

    detect_os
    ensure_system_packages
    install_go
    install_beads
    init_beads
    create_validation_script
    write_env_file
    run_validation
    print_summary

    log_info "Setup complete! Run: source $ENV_FILE"
}

main "$@"
