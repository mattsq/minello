---
name: github-api-curl
description: Using GitHub API with curl when gh CLI is unavailable. Use when GitHub operations are needed but gh command is not installed.
---

# GitHub API with curl

When `gh` CLI is not available, use curl to interact with the GitHub API directly. This skill covers common GitHub operations using the REST API.

## Base API Information

- **Base URL**: `https://api.github.com`
- **API Version**: v3 (use header: `Accept: application/vnd.github.v3+json`)
- **Rate Limit**: 60 requests/hour (unauthenticated), 5000/hour (authenticated)
- **Authentication**: Optional via `GITHUB_TOKEN` environment variable

## Common Operations

### 1. Check Workflow Runs

Get recent workflow runs for a repository:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=10
```

Get a specific workflow run:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}
```

Get jobs for a specific run:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}/jobs
```

### 2. Pull Requests

List pull requests:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/pulls?state=open&per_page=10
```

Get a specific pull request:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}
```

Create a pull request (requires authentication):

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  https://api.github.com/repos/{owner}/{repo}/pulls \
  -d '{
    "title": "PR Title",
    "body": "PR description",
    "head": "feature-branch",
    "base": "main"
  }'
```

### 3. Issues

List issues:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/issues?state=open&per_page=10
```

Get a specific issue:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}
```

Create an issue (requires authentication):

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  https://api.github.com/repos/{owner}/{repo}/issues \
  -d '{
    "title": "Issue title",
    "body": "Issue description",
    "labels": ["bug"]
  }'
```

### 4. Repository Information

Get repository details:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}
```

List branches:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/branches
```

### 5. Checks and Status

Get check runs for a specific commit:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/commits/{sha}/check-runs
```

Get status for a commit:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/{owner}/{repo}/commits/{sha}/status
```

## Getting Repository Owner and Name

From git remote:

```bash
# Get remote URL
git remote -v

# For URLs like: https://github.com/owner/repo.git or git@github.com:owner/repo.git
# Extract owner and repo using git commands
git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/\([^.]*\).*/\1\/\2/'
```

## Authentication

For operations that require authentication (creating PRs, issues, etc.):

1. Set up a GitHub Personal Access Token (PAT)
2. Store in environment variable: `export GITHUB_TOKEN="your_token_here"`
3. Include in requests: `-H "Authorization: token ${GITHUB_TOKEN}"`

**Never hardcode tokens** - always use environment variables.

## Parsing JSON Responses

### Using Python for formatting:

```bash
curl -s https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=5 | python3 -c "
import sys, json
data = json.load(sys.stdin)
for run in data['workflow_runs']:
    status = '✅' if run['conclusion'] == 'success' else '❌' if run['conclusion'] == 'failure' else '⏸️'
    print(f\"{status} {run['name']:15} | {run['head_branch']:30} | {run['conclusion']:10}\")
"
```

### Using jq (if available):

```bash
curl -s https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=5 | \
  jq -r '.workflow_runs[] | "\(.name) | \(.head_branch) | \(.conclusion)"'
```

### Using grep for simple extraction:

```bash
curl -s https://api.github.com/repos/{owner}/{repo}/actions/runs?per_page=5 | \
  grep -E '"(name|conclusion|head_branch)"'
```

## Rate Limiting

Check your rate limit status:

```bash
curl -s -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/rate_limit
```

## Common Patterns

### 1. Get latest workflow status for current branch

```bash
BRANCH=$(git branch --show-current)
REPO=$(git remote get-url origin | sed 's/.*[:/]\([^/]*\/[^.]*\).*/\1/')
curl -s https://api.github.com/repos/${REPO}/actions/runs?branch=${BRANCH}&per_page=1
```

### 2. Check if PR exists for current branch

```bash
BRANCH=$(git branch --show-current)
REPO=$(git remote get-url origin | sed 's/.*[:/]\([^/]*\/[^.]*\).*/\1/')
curl -s https://api.github.com/repos/${REPO}/pulls?head=${REPO%%/*}:${BRANCH}
```

### 3. Get failed job logs (requires downloading)

```bash
# Get run ID, then jobs, then download logs
RUN_ID=123456
curl -s https://api.github.com/repos/{owner}/{repo}/actions/runs/${RUN_ID}/jobs | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
for job in data['jobs']:
    if job['conclusion'] == 'failure':
        print(f\"Failed job: {job['name']}\")
        print(f\"URL: {job['html_url']}\")
"
```

## Error Handling

GitHub API returns standard HTTP status codes:
- **200**: Success
- **201**: Created (for POST requests)
- **204**: No Content (for DELETE requests)
- **401**: Unauthorized (bad token)
- **403**: Forbidden (rate limit or permissions)
- **404**: Not Found
- **422**: Validation Failed

Check response status:

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/{owner}/{repo})
if [ "$HTTP_CODE" -ne 200 ]; then
    echo "Error: HTTP $HTTP_CODE"
fi
```

## Best Practices

1. **Always use `-s` flag** with curl to suppress progress bar
2. **Include Accept header** for consistent API version
3. **Use authentication** when available to increase rate limits
4. **Parse JSON carefully** - use python3/jq for complex parsing
5. **Handle pagination** - API returns max 100 items per page, use `?per_page=N&page=N`
6. **Cache responses** when possible to avoid rate limits
7. **Check rate limits** before batch operations

## Pagination

For large result sets:

```bash
# Page 1
curl -s "https://api.github.com/repos/{owner}/{repo}/issues?per_page=100&page=1"

# Page 2
curl -s "https://api.github.com/repos/{owner}/{repo}/issues?per_page=100&page=2"

# Check Link header for pagination info
curl -I "https://api.github.com/repos/{owner}/{repo}/issues" | grep -i "link:"
```

## Troubleshooting

**Issue**: `curl: command not found`
- curl should be available on most systems; install if needed

**Issue**: Rate limit exceeded (403)
- Use authentication with `-H "Authorization: token ${GITHUB_TOKEN}"`
- Wait for rate limit reset (check `X-RateLimit-Reset` header)

**Issue**: JSON parsing errors
- Verify API endpoint is correct
- Check response with `curl -v` for verbose output
- Validate JSON with `| python3 -m json.tool`

## References

- GitHub REST API Documentation: https://docs.github.com/en/rest
- API Endpoints: https://docs.github.com/en/rest/overview/endpoints-available-for-github-apps
- Authentication: https://docs.github.com/en/rest/overview/authenticating-to-the-rest-api
