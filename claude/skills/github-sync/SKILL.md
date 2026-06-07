---
name: github-sync
description: "Work with GitHub — push, pull, PRs, branch management, issues. Triggers: 'push to github', 'pull from github', 'create PR', 'open pull request', 'merge PR', 'create branch', 'delete branch', 'github status', 'github issues', 'github'. Strict plan-then-confirm pattern: always explain what will happen and ask for confirmation before any write/destructive operation."
version: "1.0"
---

# GitHub Sync skill

**Critical principle:** NEVER make destructive decisions without first explaining what will happen and getting explicit confirmation. If the user's intent is unclear — **ASK**, do not assume.

---

## Setup (one-time)

### 1. Create a Personal Access Token

Go to GitHub → Settings → Developer settings → Personal access tokens → **Tokens (classic)** → Generate new token.

**Recommended scopes:**
- `repo` — full access to private repos (includes push, read, PR creation)
- `public_repo` — if working only with public repos

### 2. Store token as Windows User env var

```powershell
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', '<paste-token>', 'User')
```

⚠️ Open a new PowerShell window for the variable to become available (`$env:GITHUB_TOKEN`).

### 3. Verify

```powershell
if ($env:GITHUB_TOKEN) { "OK, token loaded ($($env:GITHUB_TOKEN.Length) chars)" } else { "MISSING — set GITHUB_TOKEN first" }
```

### 4. GitHub CLI (optional but recommended)

If `gh` CLI is available, it handles auth and PR operations more ergonomically:

```powershell
gh auth login   # follows interactive flow, stores credentials
gh auth status  # verify
```

---

## Operational Model — PLAN-THEN-CONFIRM

Every write/destructive operation follows this flow:

1. **Detect intent** — what does the user want? If unclear → **ASK** (via `AskUserQuestion`).
2. **Inspect state** — `git status`, `git log --oneline -5`, `git diff --stat`, or API GET. Gather facts.
3. **Plan in 1–3 sentences** — e.g. *"I'll push 2 commits (`abc1234`, `def5678`) to `origin/feature/auth`. `main` is not touched."*
4. **Confirm** — ask explicitly: "Shall I proceed? (yes/no)" or use `AskUserQuestion` for complex cases with options.
5. **Execute** only after "yes".
6. **Report** result concisely (1 sentence + relevant output).

**Read-only operations** (`fetch`, `status`, `log`, `diff`, PR list, issue list) → **no confirmation needed**. Just execute and report.

---

## Git CLI Operations

### Read-only (no confirmation)
| Command | What it does |
|---------|-------------|
| `git status` | Working copy state |
| `git log --oneline -10` | Recent commits |
| `git diff` / `git diff --stat` | Local changes |
| `git fetch` | Downloads remote refs (does not touch working tree) |
| `git branch -a` | All branches |

### Pull (conditional confirmation)
- If no local changes and no divergence → execute directly, report.
- If uncommitted changes exist → **STOP**, show `git status`, ask user to decide (commit / stash / abort).
- If local branch diverges from remote (merge/rebase needed) → explain situation, ask which approach.

### Commit (always confirm)
1. Show `git status` + `git diff --stat`
2. If user has not provided a commit message → **ASK** for message
3. Show plan: *"I'll stage files X, Y and create commit with message '...'. OK?"*
4. After "yes" → `git add <specific files>` (NEVER `git add -A` or `.` unless user explicitly requests)
5. `git commit -m "<message>"`

### Push (always confirm)
1. `git status`, `git log origin/<branch>..HEAD --oneline` (what will be pushed)
2. Plan: *"I'll push N commits to `origin/<branch>`."*
3. **TRIPLE WARN** if current branch is `main` or `master`: *"⚠️ Pushing directly to protected branch `main`. Is this intentional?"*
4. **NEVER** automatically: `--force`, `--force-with-lease`, `--no-verify` — all require explicit user instruction.

### Branch operations
- **Create**: ask name if not given; show source ref; confirm
- **Checkout**: if uncommitted changes exist — warn before switch
- **Delete**: confirm + double-check if branch is unmerged. NEVER delete `main`/`master`/`develop`.

### Operations NEVER to perform automatically
```
git reset --hard
git clean -fd
git push --force / --force-with-lease
git checkout . / git restore .
git branch -D
git rebase (if it rewrites published commits)
git commit --no-verify
git commit --amend (on published commit)
```
All of the above require **explicit user instruction** + clear plan + confirmation.

---

## GitHub PR Operations

Prefer `gh` CLI for PR operations when available.

### Create PR (always confirm)
**Ask the user (via `AskUserQuestion` or sequentially):**
- Source branch (default: current branch)
- Base branch (default: `main`)
- Title (suggest from last commit message, user can edit)
- Description (optional)
- Reviewers (optional)

**Show preview** before creating:
```
PR will be created:
  Source:      feature/user-login
  Base:        main
  Title:       "Add user login flow"
  Description: (3 lines)
  Reviewers:   @username
  Repo:        owner/repo

Send? (yes/no)
```

```powershell
# Via gh CLI (recommended):
gh pr create --base main --head feature/user-login --title "..." --body "..."

# Via git push + URL (if gh not available):
git push -u origin feature/user-login
# GitHub will print a URL to create the PR
```

### List PRs (read-only)
```powershell
gh pr list --state open
```
Output: table ID | Title | Author | Source→Base | Updated.

### Merge PR (confirm)
1. Ask PR number and merge method (merge / squash / rebase)
2. Show preview
3. Confirm
4. `gh pr merge <number> --<method>`

### Comment on PR / Issue (confirm)
1. Ask PR/issue number and comment text
2. Show preview of comment
3. Confirm
4. `gh pr comment <number> --body "..."` or `gh issue comment <number> --body "..."`

### List Issues (read-only)
```powershell
gh issue list --state open
```

### Create Branch (confirm)
```powershell
git checkout -b <branch-name>
git push -u origin <branch-name>
```

### Delete Branch (strict confirm)
1. Check if merged: `gh pr list --head <branch>` — if open PR exists, **warn**
2. Verify it is not `main`/`master`/`develop` — if so, **refuse**
3. Double confirmation
4. `git push origin --delete <branch>` + `git branch -d <branch>`

---

## Safety rules

| Rule | Reason |
|------|--------|
| Plan-then-confirm for all write ops | User must see what will happen |
| NEVER log `$env:GITHUB_TOKEN` in plain text | Token leak prevention |
| Mask token in error messages (`***`) | Token leak prevention |
| `git add` only specific files (not `-A`/`.`) unless on user request | Prevents accidental secret commit |
| Triple-warn for push on `main`/`master` | Protected branch protection |
| Refuse to delete `main`/`master`/`develop` even with confirmation | Hard guardrail |
| `--force`, `--no-verify`, `reset --hard` only on explicit user instruction | Destructive |
| If user is unclear → ASK, do not assume | Core principle |

---

## Error handling

| HTTP / Error | Message to user |
|-------------|----------------|
| 401 | "Token expired or invalid. Regenerate at GitHub → Settings → Developer settings → Personal access tokens and set new `GITHUB_TOKEN` env var." |
| 403 | "You don't have permission for this resource. Check token scopes (needs `repo` or `public_repo`)." |
| 404 | "Repository/PR/branch does not exist or you don't have access." |
| 5xx | "GitHub server error. Try again in a few minutes." |
| Network timeout / SSH blocked | "Cannot reach github.com via SSH. Switch to the HTTPS remote URL (`https://github.com/owner/repo.git`); Git Credential Manager handles auth on first push." |
| Token missing | Show Setup section of this skill. |

---

## Examples

### Example 1 — User: "create a PR"
```
Bot: Current branch: feature/user-login
     Last commit: "Add user login token validation"

I need a few details before creating the PR:
[AskUserQuestion with 3 questions: base branch (default main), title, reviewers]

→ After answers show preview, then confirm, then gh pr create.
```

### Example 2 — User: "delete feature/old-stuff"
```
Bot: Checking status of branch feature/old-stuff...
     - Exists locally and on origin
     - 3 commits NOT merged into main (unmerged)

⚠️ This branch has unmerged commits that would be lost:
   abc1111  WIP: refactor auth
   def2222  Test cleanup
   ghi3333  Fix proxy config

Are you sure you want to delete both local and remote branch?
[AskUserQuestion: "Yes, delete both", "Local only", "Cancel"]
```

### Example 3 — Unclear request
```
User: "do something with github"
Bot:  Not clear what you need. Can you clarify?
[AskUserQuestion with options:
  - "Sync with remote (fetch + pull)"
  - "Push local changes"
  - "Create a new PR"
  - "View open PRs"
  - "Something else (describe)"]
```
