---
name: review-pr
description: Review a GitHub pull request for code quality, security, correctness, and project conventions, then post the review as a comment on the PR. Use when the user asks to review a PR.
---

# Review a Pull Request

Perform a thorough code review on the specified pull request and post the results as a PR review comment.

## Usage

- `/review-pr` — auto-detect the PR for the current branch
- `/review-pr 42` — review PR #42
- `/review-pr owner/repo#42` — review a specific repo's PR

## Steps

### 1. Determine the PR target

- If `$ARGUMENTS` is a number, use it as the PR number for the current repo.
- If `$ARGUMENTS` is in `owner/repo#number` format, use that repo and PR number.
- If `$ARGUMENTS` is empty, detect the current branch and find its open PR with:
  ```
  gh pr view --json number,url
  ```
- If no open PR is found, inform the user and stop.

### 2. Gather context

Run these commands in parallel to collect all necessary information:

```bash
# PR metadata (title, body, base branch, changed files)
gh pr view {number} --json title,body,baseRefName,headRefName,files,additions,deletions,commits,state

# Full diff
gh pr diff {number}
```

Also read the following project files if they exist, to understand project conventions:
- `CLAUDE.md` — project development rules
- `.github/copilot-instructions.md` — code standards and architecture context
- `.github/CODEOWNERS` — ownership information

These files define project-specific conventions that should be enforced during review. If they exist, treat their rules as requirements.

### 3. Analyze the diff

Review every changed file in the diff. For each file, check the categories below. Read the full file content (not just the diff) when you need surrounding context to evaluate correctness.

#### 3a. Correctness
- Logic errors, off-by-one, null/undefined access
- Missing error handling or swallowed errors
- Race conditions in async code
- Type soundness — do type casts bypass real validation?

#### 3b. Security
- Input validation at system boundaries
- Secrets/credentials leaked in responses or logs
- Injection vulnerabilities (SQL, command, template, etc.)
- SSRF, open redirect, XSS
- Authentication/authorization gaps

#### 3c. Project conventions
Apply rules from `CLAUDE.md` and `.github/copilot-instructions.md` if they exist. Common checks:
- Does the change follow the project's established patterns and style?
- Are tests added or updated for the changed behavior?
- Are breaking changes documented?

#### 3d. Code quality
- Unnecessary complexity or over-engineering
- Dead code, unused imports
- Missing or misleading names
- Duplicated logic that should be shared

### 4. Compose the review

Structure the review comment as follows. Omit empty sections.

```markdown
## Code Review: {PR title}

### Summary
{1-2 sentence overall assessment}

### Critical (must fix before merge)
- ...

### Suggestions (recommended improvements)
- ...

### Nits (minor style / preference)
- ...

### Verdict
{One of: "LGTM", "LGTM with nits", "Request changes (see Critical)"}
```

Do NOT include praise or "positive notes" sections. Focus purely on actionable issues and improvements.

Guidelines for the review:
- Be specific — reference file paths and line numbers (e.g., `src/utils/auth.ts:142`)
- Suggest concrete fixes, not just "this is wrong"
- Keep it concise — don't restate what the code does, focus on what's wrong or could be better
- Distinguish between blocking issues and nice-to-haves
- If the diff is large, prioritize security and correctness over style

### 5. Post the review

Post the review as a regular PR comment (not a review, since the user runs this themselves):

```bash
gh pr comment {number} --body "{review content}"
```

Use a HEREDOC for the body to preserve formatting.

### 6. Report to the user

Show a brief summary of the review result and the PR URL.
