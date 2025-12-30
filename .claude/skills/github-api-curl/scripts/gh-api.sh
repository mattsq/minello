#!/usr/bin/env bash
# GitHub API helper script for common operations when gh CLI is unavailable

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get repository info from git remote
get_repo_info() {
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -z "$remote_url" ]; then
        echo "Error: Not in a git repository or no remote 'origin' found" >&2
        exit 1
    fi

    # Extract owner/repo from various URL formats
    # https://github.com/owner/repo.git
    # git@github.com:owner/repo.git
    # http://proxy/git/owner/repo
    echo "$remote_url" | sed -E 's#.*[:/]([^/]+/[^/]+?)(\.git)?$#\1#'
}

# Make authenticated API call if token is available
api_call() {
    local url=$1
    local method=${2:-GET}
    local data=${3:-}

    local headers=(-H "Accept: application/vnd.github.v3+json")

    if [ -n "${GITHUB_TOKEN:-}" ]; then
        headers+=(-H "Authorization: token ${GITHUB_TOKEN}")
    fi

    if [ -n "$data" ]; then
        curl -s -X "$method" "${headers[@]}" "$url" -d "$data"
    else
        curl -s -X "$method" "${headers[@]}" "$url"
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: gh-api.sh <command> [options]

Commands:
    runs [N]              - Show last N workflow runs (default: 10)
    run <id>              - Show details of specific workflow run
    jobs <id>             - Show jobs for a workflow run
    pr list               - List open pull requests
    pr <number>           - Show details of specific PR
    issue list            - List open issues
    issue <number>        - Show details of specific issue
    repo                  - Show repository information
    branches              - List repository branches
    rate-limit            - Check API rate limit status

Environment Variables:
    GITHUB_TOKEN          - GitHub Personal Access Token (optional, increases rate limit)

Examples:
    gh-api.sh runs 5                    # Show last 5 workflow runs
    gh-api.sh run 12345678             # Show details of run 12345678
    gh-api.sh pr list                   # List open PRs
    gh-api.sh rate-limit                # Check rate limit
EOF
}

# Format workflow runs
format_runs() {
    python3 -c '
import sys, json
data = json.load(sys.stdin)
total = data.get("total_count", 0)
print("Total runs: {}".format(total))
print()
for run in data.get("workflow_runs", []):
    conclusion = run.get("conclusion")
    status_str = run.get("status")
    if conclusion == "success":
        status = "✅"
    elif conclusion == "failure":
        status = "❌"
    elif status_str == "in_progress":
        status = "⏸️"
    else:
        status = "⚪"
    print("{} {:15} | {:35} | {:15}".format(status, run.get("name", ""), run.get("head_branch", ""), conclusion or status_str or ""))
    print("   ID: {} | {}".format(run.get("id"), run.get("created_at", "")))
    print("   {}".format(run.get("html_url", "")))
    print()
'
}

# Format pull requests
format_prs() {
    python3 -c '
import sys, json
data = json.load(sys.stdin)
for pr in data:
    state = pr.get("state", "")
    if state == "open":
        status = "🟢"
    elif state == "closed":
        status = "🔴"
    else:
        status = "🟣"
    print("{} #{} {}".format(status, pr.get("number", ""), pr.get("title", "")))
    print("   {} | {} → {}".format(pr.get("user", {}).get("login", ""), pr.get("head", {}).get("ref", ""), pr.get("base", {}).get("ref", "")))
    print("   {}".format(pr.get("html_url", "")))
    print()
'
}

# Main command dispatcher
main() {
    local command=${1:-help}
    shift || true

    case $command in
        runs)
            local count=${1:-10}
            local repo=$(get_repo_info)
            echo "Fetching workflow runs for $repo..."
            api_call "https://api.github.com/repos/$repo/actions/runs?per_page=$count" | format_runs
            ;;

        run)
            local run_id=$1
            if [ -z "$run_id" ]; then
                echo "Error: Run ID required" >&2
                exit 1
            fi
            local repo=$(get_repo_info)
            api_call "https://api.github.com/repos/$repo/actions/runs/$run_id" | python3 -m json.tool
            ;;

        jobs)
            local run_id=$1
            if [ -z "$run_id" ]; then
                echo "Error: Run ID required" >&2
                exit 1
            fi
            local repo=$(get_repo_info)
            api_call "https://api.github.com/repos/$repo/actions/runs/$run_id/jobs" | python3 -m json.tool
            ;;

        pr)
            local action=${1:-list}
            local repo=$(get_repo_info)

            if [ "$action" = "list" ]; then
                echo "Fetching pull requests for $repo..."
                api_call "https://api.github.com/repos/$repo/pulls?state=open&per_page=20" | format_prs
            else
                api_call "https://api.github.com/repos/$repo/pulls/$action" | python3 -m json.tool
            fi
            ;;

        issue)
            local action=${1:-list}
            local repo=$(get_repo_info)

            if [ "$action" = "list" ]; then
                echo "Fetching issues for $repo..."
                api_call "https://api.github.com/repos/$repo/issues?state=open&per_page=20" | python3 -m json.tool
            else
                api_call "https://api.github.com/repos/$repo/issues/$action" | python3 -m json.tool
            fi
            ;;

        repo)
            local repo=$(get_repo_info)
            api_call "https://api.github.com/repos/$repo" | python3 -m json.tool
            ;;

        branches)
            local repo=$(get_repo_info)
            echo "Fetching branches for $repo..."
            api_call "https://api.github.com/repos/$repo/branches" | python3 -c '
import sys, json
data = json.load(sys.stdin)
for branch in data:
    protected = "🔒" if branch.get("protected", False) else "  "
    print("{} {}".format(protected, branch.get("name", "")))
'
            ;;

        rate-limit)
            api_call "https://api.github.com/rate_limit" | python3 -c '
import sys, json
from datetime import datetime
data = json.load(sys.stdin)
core = data.get("resources", {}).get("core", {})
print("Core API Rate Limit:")
print("  Used: {}/{}".format(core.get("used", 0), core.get("limit", 0)))
print("  Remaining: {}".format(core.get("remaining", 0)))
reset_time = datetime.fromtimestamp(core.get("reset", 0))
print("  Resets at: {}".format(reset_time))
'
            ;;

        help|--help|-h)
            usage
            ;;

        *)
            echo "Error: Unknown command '$command'" >&2
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
