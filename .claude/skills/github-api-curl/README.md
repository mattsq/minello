# GitHub API with curl Skill

This skill provides comprehensive instructions and tools for using the GitHub API with curl when the `gh` CLI is not available.

## When to Use This Skill

This skill should be loaded when:
- GitHub operations are needed but `gh` command is not installed
- Working in environments without GitHub CLI
- Need to interact with GitHub Actions, PRs, issues, or repository data

## What This Skill Provides

### 1. SKILL.md
Comprehensive documentation covering:
- Common GitHub API operations (workflow runs, PRs, issues, branches)
- Authentication with GitHub tokens
- JSON parsing techniques (Python, jq, grep)
- Rate limiting and pagination
- Error handling
- Best practices

### 2. Helper Script (`gh-api.sh`)
A bash script that simplifies common GitHub API operations:

```bash
# Show recent workflow runs
.claude/skills/github-api-curl/scripts/gh-api.sh runs 5

# Get specific workflow run details
.claude/skills/github-api-curl/scripts/gh-api.sh run 12345678

# List open pull requests
.claude/skills/github-api-curl/scripts/gh-api.sh pr list

# Check API rate limit
.claude/skills/github-api-curl/scripts/gh-api.sh rate-limit

# List repository branches
.claude/skills/github-api-curl/scripts/gh-api.sh branches

# Show help
.claude/skills/github-api-curl/scripts/gh-api.sh --help
```

## Usage Examples

### Check Workflow Status

```bash
# Get last 10 workflow runs
curl -s https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=10

# Or use the helper script
.claude/skills/github-api-curl/scripts/gh-api.sh runs 10
```

### Create a Pull Request (requires GITHUB_TOKEN)

```bash
export GITHUB_TOKEN="your_token_here"

curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/pulls \
  -d '{
    "title": "New Feature",
    "body": "Description",
    "head": "feature-branch",
    "base": "main"
  }'
```

## Authentication

For operations requiring authentication:

1. Create a GitHub Personal Access Token at https://github.com/settings/tokens
2. Set environment variable: `export GITHUB_TOKEN="your_token"`
3. The helper script will automatically use it when available

**Note**: Never hardcode tokens in scripts or commands. Always use environment variables.

## Requirements

- `curl` (available on most systems)
- `python3` (for JSON parsing in helper script)
- `git` (for repository detection in helper script)

## API Rate Limits

- **Unauthenticated**: 60 requests/hour
- **Authenticated**: 5,000 requests/hour

Check your current rate limit status:

```bash
.claude/skills/github-api-curl/scripts/gh-api.sh rate-limit
```

## Repository Information

The helper script automatically detects the repository from your git remote:

```bash
# It extracts owner/repo from:
# - https://github.com/owner/repo.git
# - git@github.com:owner/repo.git
# - http://proxy/git/owner/repo
```

## Comparison with gh CLI

This skill provides curl-based alternatives to common `gh` commands:

| gh command | curl equivalent (via helper script) |
|------------|-------------------------------------|
| `gh run list` | `gh-api.sh runs` |
| `gh run view <id>` | `gh-api.sh run <id>` |
| `gh pr list` | `gh-api.sh pr list` |
| `gh pr view <num>` | `gh-api.sh pr <num>` |
| `gh api rate-limit` | `gh-api.sh rate-limit` |

## Documentation Reference

- GitHub REST API: https://docs.github.com/en/rest
- API Endpoints: https://docs.github.com/en/rest/overview/endpoints-available-for-github-apps
- Authentication: https://docs.github.com/en/rest/overview/authenticating-to-the-rest-api

## Contributing

This skill is part of the Claude Code skills library. To improve it:

1. Update `SKILL.md` with new API patterns
2. Enhance `scripts/gh-api.sh` with new commands
3. Add examples to this README
4. Test thoroughly in environments without `gh` CLI
