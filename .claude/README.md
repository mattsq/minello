# Claude Code Configuration

This directory contains hooks and configuration for Claude Code to ensure consistent development practices.

## Hooks

### `hooks/user-prompt-submit`

This hook runs **before every user prompt** is processed by Claude Code. It validates that all required dependencies are available:

#### What it checks:

1. **Git** - Version control system
2. **Go** - Required for beads task tracker
3. **Beads (bd)** - Issue tracking tool at `$HOME/go/bin/bd`
4. **jq** - JSON processor (optional but recommended)
5. **Project structure** - Validates CLAUDE.md and AGENTS.md exist

#### Behavior:

- **Errors** (missing critical tools): Hook exits with code 1, blocking the prompt
- **Warnings** (missing optional tools): Hook exits with code 0, allowing the prompt to continue
- **Success**: Hook exits with code 0, prompt proceeds normally

#### Bypassing the hook:

If you need to temporarily disable the dependency check:

```bash
export CLAUDE_SKIP_DEPENDENCY_CHECK=1
```

## Installation of Dependencies

If the hook reports missing dependencies, run the setup script:

```bash
bash scripts/codex-build.sh
```

This will install:
- Go programming language
- Beads task tracker
- Required system packages
- Validation scripts

## For Codex Web Agents

The `codex-build.sh` script is designed for Codex Web agents working on this iOS project. Since Codex runs on Linux but this is an iOS/macOS project, the script focuses on:

- Installing task tracking tools (beads)
- Setting up validation scripts
- Ensuring version control is configured
- Preparing the environment for code review and task management

**Note**: Actual iOS builds require macOS with Xcode. The Codex setup enables code review, planning, and task tracking work.

## Troubleshooting

### "Beads not found"

```bash
# Install Go first
curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
export PATH=/usr/local/go/bin:$PATH

# Install beads
go install github.com/beadsland/beads/cmd/bd@latest
```

### "Not inside a git repository"

```bash
git init
git add .
git commit -m "Initial commit"
```

### Hook not running

Ensure the hook is executable:

```bash
chmod +x .claude/hooks/user-prompt-submit
```

## References

- [Claude Code Hooks Documentation](https://developers.anthropic.com/claude-code/hooks)
- [Beads Issue Tracker](https://github.com/beadsland/beads)
- [Codex Web Best Practices](https://developers.openai.com/codex/guides/agents-md/)
