# AI Agents Guide for Minello

This document provides guidance for AI assistants working on the Minello project.

## Project Overview

Minello is a Swift-based development project that uses the Codex toolchain. The project includes:

- Swift 5.10.1 toolchain setup
- SwiftLint for code quality
- swift-format for code formatting
- Ubuntu 22.04 target environment

## Repository Structure

```
minello/
├── scripts/          # Build and setup scripts
│   └── codex-build.sh  # Main toolchain installation script
├── AGENTS.md         # This file - AI agent guidance
├── CLAUDE.md         # Quick reference pointing to this file
└── README.md         # Project documentation
```

## Development Environment Setup

The project uses a custom Codex environment located at `~/.codex/`. To set up:

```bash
./scripts/codex-build.sh
source ~/.codex/env.sh
```

This script:
- Installs required apt packages
- Downloads and installs Swift 5.10.1
- Installs SwiftLint 0.55.1
- Installs swift-format (swift-510.0.0-RELEASE)
- Creates environment configuration at `~/.codex/env.sh`

## Important Environment Variables

- `HOMECOOKED_ROOT`: Points to the HomeCooked directory
- `HOMECOOKED_TOOLING`: Points to HomeCooked/Tooling
- `PATH`: Includes Swift binaries and codex tools
- `LD_LIBRARY_PATH`: Includes Swift libraries

## Git Workflow

### Branch Naming Convention
- Feature branches should follow the pattern: `claude/<description>-<session-id>`
- Current development branch: `claude/init-claude-md-ojBpm`

### Push Requirements
- Always use: `git push -u origin <branch-name>`
- Branch must start with `claude/` and end with matching session ID
- Retry on network errors with exponential backoff (2s, 4s, 8s, 16s)

## Code Quality Standards

- Use SwiftLint for linting
- Use swift-format for formatting
- Follow Swift standard naming conventions
- Write clear, descriptive commit messages

## Working with AI Assistants

When AI assistants work on this project:

1. **Read before modifying**: Always read files before making changes
2. **Understand context**: Review related code and documentation
3. **Follow conventions**: Match existing code style and patterns
4. **Test changes**: Ensure code builds and passes linting
5. **Commit properly**: Write clear commit messages explaining the "why"

## File Locations

- Toolchains: `~/.codex/toolchains/`
- Binary tools: `~/.codex/bin/`
- Environment config: `~/.codex/env.sh`

## Common Tasks

### Building the Project
```bash
source ~/.codex/env.sh
swift build
```

### Running Linting
```bash
swiftlint
```

### Formatting Code
```bash
swift-format -i <file>
```

## Notes for AI Agents

- This is a Linux-only project (Ubuntu 22.04)
- The codex-build.sh script handles all toolchain setup
- Swift version is pinned to 5.10.1
- Always activate the environment before Swift operations
