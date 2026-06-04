# 📘 Day 26 – GitHub CLI: Reference & Master Command Guide

> **"A master DevOps engineer does not rely on web browsers to deploy, verify, or manage repositories. In automation-first environments, controlling GitHub via the command-line interface (`gh`) is critical. It enables seamless scripting, rapid issue and PR turnaround, and direct CI/CD workflow control directly from your development workspace."**

Welcome to the **GitHub CLI (`gh`) Reference & Master Command Guide** compiled for the **90 Days of DevOps** challenge! This document consolidates all essential, advanced, and automation-friendly `gh` commands practiced on **Day 26**. It serves as a high-density, zero-friction developer cheat sheet covering authentication, repository lifecycles, issue tracking, pull requests, automated workflow runs, REST API operations, Gists, and custom terminal aliases.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | GitHub CLI (`gh`) Master Command Reference: Authentication, Repositories, Issues, PRs, CI/CD Actions, REST/GraphQL API Calls, and Custom Aliases |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Interface** | GitHub CLI (`gh`) v2.50.0 / macOS Terminal |
| **Target Document** | [git-commands.md](git-commands.md) |
| **Key Command Interfaces** | `gh auth`, `gh repo`, `gh issue`, `gh pr`, `gh run`, `gh workflow`, `gh api`, `gh alias` |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-26/` |

---

## 📑 Table of Contents
1. [📊 Master GitHub CLI Commands Matrix](#-master-github-cli-commands-matrix)
2. [⚙️ 1. Authentication & Configuration](#-1-authentication--configuration)
3. [📁 2. Repository Lifecycle Management](#-2-repository-lifecycle-management)
4. [🐞 3. Interactive Issue Tracking](#-3-interactive-issue-tracking)
5. [🔀 4. Advanced Pull Request Workflows](#-4-advanced-pull-request-workflows)
6. [🤖 5. CI/CD Pipeline & GitHub Actions Orchestration](#-5-cicd-pipeline--github-actions-orchestration)
7. [💡 6. DevOps Productivity Hacks (API, Gist, Release, Search & Alias)](#-6-devops-productivity-hacks-api-gist-release-search--alias)
8. [🎨 Visual Verification Terminal Session](#-visual-verification-terminal-session)

---

## 📊 Master GitHub CLI Commands Matrix

Below is a syntax lookup matrix summarizing all operations covered on Day 26:

| Category | Command Syntax | Description (1 Line Summary) | DevOps Use Case |
| :--- | :--- | :--- | :--- |
| **Setup & Auth** | `gh auth login` | Authenticates CLI with active GitHub account. | Logging into a secure workstation. |
| **Setup & Auth** | `gh auth status` | Validates session health, scopes, and active account. | Confirming API scopes before starting. |
| **Setup & Auth** | `gh auth logout` | Terminates active CLI session and clears tokens. | De-authorizing a temporary server. |
| **Repositories** | `gh repo create <name>` | Provision a brand-new repo directly on GitHub. | Bootstrapping fresh service environments. |
| **Repositories** | `gh repo clone <repo>` | Copies target GitHub repository locally. | Zero-friction local checkout of a team repo. |
| **Repositories** | `gh repo view` | Renders active repository metadata and its README. | Quick command line audit of local workspace. |
| **Repositories** | `gh repo list` | Displays list of repositories owned or contributed to. | Auditing projects on your corporate account. |
| **Repositories** | `gh repo delete <repo>`| Destroys targeted GitHub repository permanently. | Programmatic cleanup of sandbox repositories. |
| **Issues** | `gh issue create` | Creates a new issue ticket with labels and owners. | Logging bug reports directly during debugging. |
| **Issues** | `gh issue list` | Lists open issues on active repository. | Auditing current workload/outstanding bugs. |
| **Issues** | `gh issue view <num>` | Displays detailed conversation thread of a ticket. | Reviewing a bug description without browser tabs. |
| **Issues** | `gh issue close <num>` | Closes specified ticket with optional review comment. | Updating project status directly from hotfix commit. |
| **Pull Requests**| `gh pr create --fill` | Provison new PR auto-populating metadata from Git. | Rapid code submission to start code review. |
| **Pull Requests**| `gh pr list` | Displays list of open pull requests on the repository. | Checking team review queue during standups. |
| **Pull Requests**| `gh pr checkout <num>`| Downloads PR branch and switches active focus. | Fast local testing/validation of a peer's code. |
| **Pull Requests**| `gh pr diff <num>` | Displays patch difference of specified PR. | Line-by-line review of incoming modifications. |
| **Pull Requests**| `gh pr checks <num>` | Validates status of all active CI/CD checks. | Ensuring tests are passing before merging. |
| **Pull Requests**| `gh pr review --approve`| Submits formal PR approval with comments. | Finalizing local validation and signing off. |
| **Pull Requests**| `gh pr merge --squash` | Merges code, squashes history, cleans up branch. | Finalizing feature integration with a clean log. |
| **GitHub Actions**| `gh run list` | Lists recent CI/CD pipeline runs. | Monitoring deployment success rates. |
| **GitHub Actions**| `gh run view <id>` | Audits logs and statuses of specific workflow jobs. | Post-mortem analysis of failed staging runs. |
| **GitHub Actions**| `gh run watch <id>` | Streams live console logs for executing workflows. | Interactive monitoring of major production deploys. |
| **Actions Config**| `gh workflow run <file>`| Triggers target manual workflow run. | Triggering target ad-hoc release runs. |
| **Advanced Hacks**| `gh api <endpoint>` | Executes raw GitHub REST/GraphQL API queries. | Automating custom metric or metadata reports. |
| **Advanced Hacks**| `gh gist create <file>`| Provisions a code gist for quick code share. | Creating quick code pastes during debugging. |
| **Advanced Hacks**| `gh release create <tag>`| Automates repository release publishing. | Triggering target release tag processes. |
| **Advanced Hacks**| `gh alias set <name> <cmd>`| Configures custom shortcut command aliases. | Reducing multi-step CLI operations to 2-3 keystrokes. |

---

## ⚙️ 1. Authentication & Configuration

Before performing operations, authenticating the CLI defines the scope and security boundaries for API requests.

### A. Authenticate with GitHub
* **Syntax:** `gh auth login`
* **Interactive Options Selectors:**
  * Host: `GitHub.com` or `GitHub Enterprise Server`
  * Protocol: `HTTPS` or `SSH`
  * Authentication: `Web Browser` or `Paste Personal Access Token`

### B. Verify active session health
* **Syntax:** `gh auth status`
* **Output:**
  ```text
  github.com
    ✓ Logged in to github.com as alex-dev (soopres: repo, read:user, workflow, gist)
    ✓ Configured git to use 'gh' credential helper
    ✓ Token: gho_************************************
  ```

### C. Log out of active sessions
* **Syntax:** `gh auth logout`
* **Output:**
  ```text
  ✓ Logged out of github.com
  ```

---

## 📁 2. Repository Lifecycle Management

Provisoning, cloning, viewing, and tearing down remote repos directly from the console.

### A. Create a New Remote Repository
* **Syntax:** `gh repo create <repo-name> --<visibility> --description "<desc>" --clone`
* **Example:** `gh repo create sandbox-app --public --description "NodeJS Sandbox Environment" --clone`
* **Output:**
  ```text
  ✓ Created repository alex-dev/sandbox-app on GitHub
  Cloning into 'sandbox-app'...
  warning: You appear to have cloned an empty repository.
  Initialized empty Git repository in /Users/alex-dev/sandbox-app/.git/
  ```

### B. Clone an Existing Repository
* **Syntax:** `gh repo clone <owner>/<repo-name>`
* **Example:** `gh repo clone rajatmehta2/90DaysOfDevOps`
* **Output:**
  ```text
  Cloning into '90DaysOfDevOps'...
  remote: Enumerating objects: 1540, done.
  Receiving objects: 100% (1540/1540), 12.42 MiB | 8.42 MiB/s, done.
  ```

### C. View Active Workspace Repo Details
* **Syntax:** `gh repo view`
* **Output:**
  ```text
  alex-dev/sandbox-app
  NodeJS Sandbox Environment

  README
  No README content found. Add a README.md file to get started.
  ```

### D. Delete a Repository (Use with Caution!)
* **Syntax:** `gh repo delete <owner>/<repo> --confirm`
* **Example:** `gh repo delete alex-dev/sandbox-app --confirm`
* **Output:**
  ```text
  ✓ Deleted repository alex-dev/sandbox-app
  ```

---

## 🐞 3. Interactive Issue Tracking

Logging, reviewing, and closing issue tickets keeps tracking metadata tightly aligned with implementation.

### A. Create a New Issue Ticket
* **Syntax:** `gh issue create --title "<title>" --body "<body>" --label "<label-1,label-2>"`
* **Example:** `gh issue create --title "bug: high memory leak on dashboard init" --body "Heap utilization climbs to 98% within 2 minutes." --label "bug, high-priority"`
* **Output:**
  ```text
  ✓ Created issue #42 in alex-dev/modern-react-app
  https://github.com/alex-dev/modern-react-app/issues/42
  ```

### B. List Open Issue Tickets
* **Syntax:** `gh issue list`
* **Output:**
  ```text
  Showing 2 of 2 open issues in alex-dev/modern-react-app

  #42  bug: high memory leak on dashboard init  (bug, high-priority)
  #38  feature: implement dark mode layout      (enhancement)
  ```

### C. Inspect Issue Thread
* **Syntax:** `gh issue view <issue-number>`
* **Example:** `gh issue view 42`
* **Output:**
  ```text
  bug: high memory leak on dashboard init #42
  Open • alex-dev opened about 1 minute ago • 0 comments

    Heap utilization climbs to 98% within 2 minutes.

  Labels: bug, high-priority
  ```

### D. Close Staged Issue
* **Syntax:** `gh issue close <issue-number> --comment "<closing-notes>"`
* **Example:** `gh issue close 42 --comment "Resolved. Optimized component rendering cycle."`
* **Output:**
  ```text
  ✓ Closed issue #42 in alex-dev/modern-react-app
  ```

---

## 🔀 4. Advanced Pull Request Workflows

Provisional management, code reviews, status checking, and merging pull requests directly from the workspace terminal.

### A. Create a New Pull Request
* **Syntax:** `gh pr create --fill --label "<labels>"`
* **Note:** The `--fill` flag automatically takes commit titles and descriptions to prevent manual prompting.
* **Example:** `gh pr create --fill --label "documentation"`
* **Output:**
  ```text
  ✓ Created pull request #43 for alex-dev/modern-react-app
  https://github.com/alex-dev/modern-react-app/pull/43
  ```

### B. Check Active Pull Request Status
* **Syntax:** `gh pr status`
* **Output:**
  ```text
  Relevant PRs in alex-dev/modern-react-app

  Current branch
    #43  docs: compose advanced GitHub CLI cheatsheet [feature/gh-cli-docs]
      ✓ Checks passing: 2 successful
      - Reviewers: None assigned
  ```

### C. Inspect PR Diff
* **Syntax:** `gh pr diff <pr-number>`
* **Example:** `gh pr diff 43`
* **Output:**
  ```diff
  diff --git a/CLI_GUIDE.md b/CLI_GUIDE.md
  new file mode 100644
  index 0000000..d4f5a6b
  --- /dev/null
  +++ b/CLI_GUIDE.md
  @@ -0,0 +1 @@
  +# GitHub CLI Mastery
  ```

### D. Review PR (Approve / Request Changes)
* **Syntax:** `gh pr review <number> --approve --body "<comment>"`
* **Example:** `gh pr review 43 --approve --body "Code looks optimized. Local tests passed."`
* **Output:**
  ```text
  ✓ Approved pull request #43
  ```

### E. Merge Pull Request
* **Syntax:** `gh pr merge <number> --squash --delete-branch`
* **Example:** `gh pr merge 43 --squash --delete-branch`
* **Output:**
  ```text
  ✓ Squashed and merged pull request #43 (docs: compose advanced GitHub CLI cheatsheet)
  ✓ Deleted branch feature/gh-cli-docs and switched to branch main
  ✓ Deleted remote branch feature/gh-cli-docs
  ```

---

## 🤖 5. CI/CD Pipeline & GitHub Actions Orchestration

Providing monitoring, tracing, and debugging over GitHub Actions runs directly on the local terminal.

### A. List Workflow Runs
* **Syntax:** `gh run list --limit <number>`
* **Output:**
  ```text
  STATUS  NAME                  EVENT   BRANCH  WORKFLOW     RUN ID      ATTEMPT  ELAPSED
  ✓       Integration Tests     push    main    ci.yml       9876543210  1        2m 14s
  ✗       Staging Deploy        push    main    deploy.yml   9876543209  1        1m 45s
  ```

### B. View a Specific Run Status and Logs
* **Syntax:** `gh run view <run-id>`
* **Example:** `gh run view 9876543209`
* **Output:**
  ```text
  ✗ Staging Deploy #9876543209
  Triggered by: push • Branch: main • Commit: a1b2c3d
  Failed 3 minutes ago • Took 1m 45s

  JOBS
  ✗ Deploy to AWS ECS (ID 123456)
    ✗ Step: Run Docker Build & Push (Failed with Exit Code 1)
  ```

### C. Live Watch Active CI/CD Runs
* **Syntax:** `gh run watch <run-id>`
* **Effect:** Streams active workflow step updates to the console, alerting upon completion or failure.

### D. Trigger Workflow Manually (ad-hoc runs)
* **Syntax:** `gh workflow run <workflow-filename> -f <input-parameter>=<value>`
* **Example:** `gh workflow run deploy.yml -f env=staging -f service=auth`
* **Output:**
  ```text
  ✓ Created workflow dispatch event for deploy.yml on branch main
  ```

---

## 💡 6. DevOps Productivity Hacks (API, Gist, Release, Search & Alias)

Beyond basic workflows, unlocking advanced namespaces accelerates sharing, release deployment, and raw platform access.

### A. Raw API Integration (`gh api`)
Query any remote REST/GraphQL resource directly, utilizing templates for custom rendering:
```bash
# Query repo details
$ gh api repos/alex-dev/modern-react-app --template 'Stars: {{.stargazers_count}} | Open Issues: {{.open_issues_count}}'
Stars: 124 | Open Issues: 2
```

### B. Instant Pasteboard Sharing (`gh gist`)
Upload text files, logs, or scripts instantly to secure Gists:
```bash
# Create a public Gist containing failure logs
$ gh gist create build_fail.log --desc "CI Docker build error logs"
https://gist.github.com/alex-dev/987654321fedcba
```

### C. Automated Release Provisioning (`gh release`)
Create version releases, uploading build bundles and compiling changelogs programmatically:
```bash
# Create a GitHub Release
$ gh release create v1.1.0 --title "Release v1.1.0" --notes "Bugfix: Database timeout resolved."
✓ Created release v1.1.0 in alex-dev/modern-react-app
https://github.com/alex-dev/modern-react-app/releases/tag/v1.1.0
```

### D. Global Repository Searching (`gh search repos`)
Locate public repositories by tags, stars, or contents directly:
```bash
# Search for top-rated kubernetes roles
$ gh search repos "kubernetes role" --limit 2
geerlingguy/ansible-role-kubernetes  Ansible Role - Kubernetes  public  1820 stars
kubernetes-sigs/kubespray            Deploy Kubernetes clusters  public  14500 stars
```

### E. Custom Shortcuts (`gh alias`)
Create convenient shorthands to substitute long, multi-option syntaxes:
```bash
# Alias to list my own open pull requests
$ gh alias set myprs "pr list --author @me"
✓ Added alias 'myprs' for 'pr list --author @me'

# Execution:
$ gh myprs
Showing 1 of 1 open PR owned by you...
#43  docs: compose advanced GitHub CLI cheatsheet [feature/gh-cli-docs]
```

---

## 🎨 Visual Verification Terminal Session

Below is the verified local-to-remote terminal integration dashboard illustrating active execution of GitHub CLI operations:

![GitHub CLI Terminal Session Dashboard](github_cli_screenshot.png)

---

Day 26 Complete 📘

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*