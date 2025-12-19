#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -s) != "Linux" ]]; then
    echo "[codex-setup] This script only supports Linux hosts." >&2
    exit 1
fi

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOMECOOKED_ROOT="$REPO_ROOT/HomeCooked"
CODEX_HOME="$HOME/.codex"
TOOLCHAIN_ROOT="$CODEX_HOME/toolchains"
BIN_DIR="$CODEX_HOME/bin"
ENV_FILE="$CODEX_HOME/env.sh"
SWIFT_VERSION="5.10.1"
UBUNTU_VERSION="22.04"
SWIFT_ARCHIVE="swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz"
SWIFT_DIR="$TOOLCHAIN_ROOT/${SWIFT_ARCHIVE%.tar.gz}"
APT_PACKAGES=(
    build-essential
    clang
    curl
    git
    libblocksruntime-dev
    libcurl4-openssl-dev
    libicu-dev
    libncurses5-dev
    libsqlite3-dev
    libssl-dev
    libxml2-dev
    pkg-config
    tar
    unzip
    xz-utils
)

run_sudo() {
    if [[ $EUID -ne 0 ]]; then
        sudo "$@"
    else
        "$@"
    fi
}

ensure_apt_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "[codex-setup] Only apt-based distributions are supported." >&2
        exit 1
    fi

    run_sudo apt-get update -y
    run_sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
}

install_swift() {
    mkdir -p "$TOOLCHAIN_ROOT"
    if [[ -x "$SWIFT_DIR/usr/bin/swift" ]]; then
        return
    fi

    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu${UBUNTU_VERSION}/${SWIFT_ARCHIVE}"
    echo "[codex-setup] Downloading Swift ${SWIFT_VERSION} from ${SWIFT_URL}" >&2
    curl -L "$SWIFT_URL" -o "$tmp_dir/$SWIFT_ARCHIVE"
    tar -xzf "$tmp_dir/$SWIFT_ARCHIVE" -C "$TOOLCHAIN_ROOT"
    rm -rf "$tmp_dir"
    trap - EXIT
}

install_swift_tool() {
    local repo=$1
    local tag=$2
    local product=$3

    mkdir -p "$BIN_DIR"
    if [[ -x "$BIN_DIR/$product" ]]; then
        return
    fi

    local work_dir
    work_dir=$(mktemp -d)
    git clone --depth=1 --branch "$tag" "$repo" "$work_dir/src"
    pushd "$work_dir/src" >/dev/null
    export PATH="$SWIFT_DIR/usr/bin:$PATH"
    export LD_LIBRARY_PATH="$SWIFT_DIR/usr/lib/swift/linux:${LD_LIBRARY_PATH:-}"
    swift build -c release --product "$product"
    cp ".build/release/$product" "$BIN_DIR/$product"
    popd >/dev/null
    rm -rf "$work_dir"
}

write_env_file() {
    mkdir -p "$CODEX_HOME"
    cat >"$ENV_FILE" <<EOF2
# shellcheck shell=bash
export PATH="$SWIFT_DIR/usr/bin:$BIN_DIR:\$PATH"
export LD_LIBRARY_PATH="$SWIFT_DIR/usr/lib/swift/linux:\${LD_LIBRARY_PATH:-}"
export HOMECOOKED_ROOT="$HOMECOOKED_ROOT"
export HOMECOOKED_TOOLING="$HOMECOOKED_ROOT/Tooling"
EOF2
    chmod +x "$ENV_FILE"
}

print_summary() {
    cat <<EOF2
[codex-setup] Environment prepared.
- Swift toolchain: $SWIFT_DIR
- Tools directory: $BIN_DIR (swiftlint, swift-format)
- Repo root: $REPO_ROOT

Activate with: source "$ENV_FILE"
EOF2
}

main() {
    ensure_apt_packages
    install_swift
    install_swift_tool "https://github.com/realm/SwiftLint.git" "0.55.1" swiftlint
    install_swift_tool "https://github.com/apple/swift-format.git" "swift-510.0.0-RELEASE" swift-format
    write_env_file
    print_summary
}

main "$@"
