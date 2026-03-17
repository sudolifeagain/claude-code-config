---
name: copilot-review
description: Request a GitHub Copilot code review on a pull request. Use when the user wants Copilot to review a PR.
disable-model-invocation: true
---

# Request Copilot Review on a PR

Request a GitHub Copilot review on the specified pull request.

## Usage

- `/copilot-review` — auto-detect the PR for the current branch
- `/copilot-review 5` — request review on PR #5
- `/copilot-review owner/repo#5` — request review on a specific repo's PR

## Steps

1. **Determine the PR target:**
   - If `$ARGUMENTS` is a number, use it as the PR number for the current repo.
   - If `$ARGUMENTS` is in `owner/repo#number` format, use that repo and PR number.
   - If `$ARGUMENTS` is empty, detect the current branch and find its open PR with:
     ```
     gh pr view --json number,url
     ```
   - If no open PR is found, inform the user and stop.

2. **Request the Copilot review** using the GitHub API:
   ```
   gh api repos/{owner}/{repo}/pulls/{number}/requested_reviewers \
     -X POST \
     -f "reviewers[]=copilot-pull-request-reviewer[bot]"
   ```

3. **Report the result** to the user — show the PR URL and confirm that Copilot review was requested.

4. **If the API returns an error**, show the error message. Common issues:
   - Copilot code review is not enabled for the repository.
   - The PR is already closed or merged.
   - Insufficient permissions.
