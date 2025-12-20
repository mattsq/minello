# Scripts Documentation

This directory contains utility scripts for the HomeCooked project.

## codex-build.sh

**Purpose**: Setup script for Codex Web agents working on this iOS project.

### What it does:

1. **Installs Go** (v1.22.0) - Required for beads task tracker
2. **Installs Beads** - Git-backed issue tracking system
3. **Creates validation tools** - Project structure validation script
4. **Sets up environment** - Creates ~/.codex/env.sh with necessary paths

### Usage:

```bash
# Run the setup script
bash scripts/codex-build.sh

# Activate the environment
source ~/.codex/env.sh

# Validate project structure
validate-project
```

### Environment created:

The script creates the following structure:

```
~/.codex/
├── bin/
│   └── validate-homecooked    # Project validation script
├── env.sh                      # Environment activation script
└── toolchains/                 # (reserved for future use)
```

### Key features:

- **OS detection**: Works on Linux (Ubuntu, Debian, RHEL) and macOS
- **Idempotent**: Safe to run multiple times
- **Non-destructive**: Won't reinstall if tools already exist
- **Colored output**: Clear status messages for each step

### Why not build iOS apps?

This is an iOS/SwiftUI project that requires macOS + Xcode to build. Codex Web runs on Linux, so this script focuses on:

- Task tracking with beads
- Code validation and linting
- Project structure checks
- Environment setup for code review

Actual iOS builds must be done on macOS with Xcode.

### Installed tools:

After running the script, you'll have:

| Tool | Location | Purpose |
|------|----------|---------|
| Go | `/usr/local/go/bin/go` | Required for beads |
| Beads (bd) | `$HOME/go/bin/bd` | Issue tracking |
| Validator | `~/.codex/bin/validate-homecooked` | Project validation |

### Troubleshooting:

**Error: "Only apt-based distributions are supported"**
- The script supports apt (Ubuntu/Debian), yum (RHEL/CentOS), and brew (macOS)
- For other systems, install dependencies manually: git, curl, jq, sqlite3

**Error: "Failed to install beads"**
- Ensure Go is properly installed: `go version`
- Check internet connectivity for downloading packages
- Try manual install: `go install github.com/beadsland/beads/cmd/bd@latest`

**Script hangs during Go download**
- Go archives are ~130MB, download may take time on slow connections
- Press Ctrl+C and retry, or download manually from https://go.dev/dl/

### For Codex Web agents:

This script should be run automatically during Codex Web session initialization. The setup is designed to:

1. ✓ Provide task tracking via beads
2. ✓ Enable code validation
3. ✓ Ensure version control is configured
4. ✓ Create a consistent development environment

### References:

- [Codex Web Best Practices](https://developers.openai.com/codex/guides/agents-md/)
- [Beads Documentation](https://github.com/beadsland/beads)
- [Go Installation Guide](https://go.dev/doc/install)
