# Minello

A Swift-based development project using the Codex toolchain.

## Overview

Minello provides a complete Swift development environment setup for Ubuntu 22.04 systems, including automated installation of the Swift toolchain, SwiftLint, and swift-format.

## Requirements

- **OS**: Ubuntu 22.04 (Linux only)
- **Swift**: 5.10.1
- **Build Tools**: clang, build-essential, and various development libraries

## Quick Start

### 1. Install the Codex Environment

```bash
./scripts/codex-build.sh
```

This script will:
- Install required system packages via apt
- Download and install Swift 5.10.1
- Install SwiftLint 0.55.1
- Install swift-format (swift-510.0.0-RELEASE)
- Configure the environment at `~/.codex/`

### 2. Activate the Environment

```bash
source ~/.codex/env.sh
```

### 3. Verify Installation

```bash
swift --version
swiftlint version
swift-format --version
```

## Project Structure

```
minello/
├── scripts/
│   └── codex-build.sh    # Codex environment setup script
├── AGENTS.md             # AI assistant guide
├── CLAUDE.md             # Quick reference for Claude AI
└── README.md             # This file
```

## Environment Details

After running the setup script, your environment will include:

- **Swift Toolchain**: `~/.codex/toolchains/swift-5.10.1-RELEASE-ubuntu22.04/`
- **Binary Tools**: `~/.codex/bin/` (swiftlint, swift-format)
- **Environment Config**: `~/.codex/env.sh`

### Environment Variables

The setup configures:
- `PATH`: Includes Swift binaries and codex tools
- `LD_LIBRARY_PATH`: Includes Swift libraries
- `HOMECOOKED_ROOT`: Points to HomeCooked directory
- `HOMECOOKED_TOOLING`: Points to HomeCooked/Tooling directory

## Development

### Building

```bash
source ~/.codex/env.sh
swift build
```

### Code Quality

**Linting:**
```bash
swiftlint
```

**Formatting:**
```bash
swift-format -i <file>
```

## Contributing

This project uses a specific Git workflow for AI-assisted development. See [AGENTS.md](./AGENTS.md) for detailed guidelines.

## License

[License information to be added]

## Support

For AI assistants working on this project, please refer to [AGENTS.md](./AGENTS.md) for comprehensive guidance.
