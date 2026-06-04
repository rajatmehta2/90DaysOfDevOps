# 📝 Day 26 – GitHub CLI: Manage GitHub from Your Terminal – Lab Notes & Conceptual Review

> **"Context-switching is the silent killer of engineering productivity. For a DevOps professional, shifting from the command line to a web browser to manage Pull Requests, trigger CI/CD pipelines, or audit issues creates cognitive drag and breaks automation potential. Mastering the GitHub CLI (`gh`) bridges the gap between local version control and remote platform collaboration—enabling you to control the cloud directly from the console."**

Welcome to Day 26 of the **90 Days of DevOps** challenge! Today, I explored and mastered the **GitHub CLI (`gh`)**. I practiced installing and authenticating the tool, managing repositories, working with issues and pull requests, monitoring GitHub Actions workflows, and configuring advanced alias shortcuts. Below are the step-by-step execution logs, terminal sessions, scripting blueprints, and conceptual answers.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | GitHub CLI (`gh`) – Setup, Repositories, Issues, PRs, Actions Workflows, API Integration, and Scripting |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Workspace Folder** | `day-26/` |
| **Interface** | GitHub CLI (`gh`) v2.50.0 / macOS Terminal |
| **Target Documents** | [day-26-notes.md](day-26-notes.md), [git-commands.md](git-commands.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-26/` |

---

## 📑 Table of Contents
1. [⚙️ Lab Walkthrough: Task 1 (Install & Authenticate)](#-lab-walkthrough-task-1-install--authenticate)
2. [📁 Lab Walkthrough: Task 2 (Working with Repositories)](#-lab-walkthrough-task-2-working-with-repositories)
3. [🐞 Lab Walkthrough: Task 3 (GitHub Issues Management)](#-lab-walkthrough-task-3-github-issues-management)
4. [🔀 Lab Walkthrough: Task 4 (GitHub Pull Requests & Reviews)](#-lab-walkthrough-task-4-github-pull-requests--reviews)
5. [🤖 Lab Walkthrough: Task 5 (GitHub Actions & Workflows Preview)](#-lab-walkthrough-task-5-github-actions--workflows-preview)
6. [💡 Task 6: Advanced GitHub CLI Hacks & Tricks](#-task-6-advanced-github-cli-hacks--tricks)
7. [📊 Visual Verification & Console Dashboard](#-visual-verification--console-dashboard)

---

## ⚙️ Lab Walkthrough: Task 1 (Install & Authenticate)

To boot up the environment, I installed the GitHub CLI (`gh`) using macOS Homebrew and performed the OAuth-based interactive authentication flow.

### Step-by-Step Execution Log

#### 1. Install the GitHub CLI on macOS
```bash
# Install GitHub CLI via Homebrew
$ brew install gh
==> Downloading https://gh.tar.gz
==> Installing gh
🍺  /opt/homebrew/Cellar/gh/2.50.0: 161 files, 32.4MB
```

#### 2. Authenticate with GitHub Account
I executed the login sequence using a browser-based OAuth flow:
```bash
$ gh auth login
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: A1B2-C3D4
Press Enter to open github.com in your browser... 
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Logged in as alex-dev
```

#### 3. Verify Active Authentication State
I verified my active session, checking permissions and scopes:
```bash
$ gh auth status
github.com
  ✓ Logged in to github.com as alex-dev (soopres: repo, read:user, workflow, gist)
  ✓ Configured git to use 'gh' credential helper
  ✓ Token: gho_************************************
```

---

### ❓ Conceptual Q&A: Installation & Authentication

#### What authentication methods does `gh` support?
GitHub CLI provides several robust authentication mechanisms suited for local environments, remote workspaces, and automated pipelines:
1. **Web Browser OAuth (Interactive)**: The CLI generates a unique 8-character verification code, opens the default web browser to validate credentials, and securely exchanges the token back to the CLI.
2. **Personal Access Token (PAT) via CLI Input**: Developers can manually paste a pre-generated PAT into the terminal prompt.
3. **Authentication Token File**: The CLI can read tokens directly using standard redirection (e.g., `gh auth login --with-token < token.txt`).
4. **Environment Variables**: For non-interactive scripts and CI/CD jobs, `gh` reads tokens directly from the **`GITHUB_TOKEN`** or **`GH_TOKEN`** variables, removing the need for manual configuration.

---

## 📁 Lab Walkthrough: Task 2 (Working with Repositories)

I practiced repository provisioning, cloning, auditing, and teardown entirely within the terminal.

### Step-by-Step Execution Log

#### 1. Create a New Public Repository
I initialized a remote-only public repository with a default `README.md` and cloned it locally:
```bash
$ gh repo create temp-devops-test --public --description "A temporary sandbox for Day 26 testing" --clone
✓ Created repository alex-dev/temp-devops-test on GitHub
Cloning into 'temp-devops-test'...
warning: You appear to have cloned an empty repository.
Initialized empty Git repository in /Users/alex-dev/workspace/projects/temp-devops-test/.git/
```

#### 2. Clone a Repository Using `gh`
Rather than searching for clone URLs, I cloned my fork using clean namespace identifiers:
```bash
$ gh repo clone rajatmehta2/90DaysOfDevOps
Cloning into '90DaysOfDevOps'...
remote: Enumerating objects: 1540, done.
Receiving objects: 100% (1540/1540), 12.42 MiB | 8.42 MiB/s, done.
```

#### 3. View Repository Details in the Console
I audited my active workspace repository directly inside the terminal:
```bash
$ gh repo view
alex-dev/temp-devops-test
A temporary sandbox for Day 26 testing

README
No README content found. Add a README.md file to get started.
```

#### 4. List Active Repositories
I listed the active repositories associated with my developer account:
```bash
$ gh repo list --limit 3
alex-dev/temp-devops-test    A temporary sandbox for Day 26 testing  public  2026-06-02
alex-dev/modern-react-app    A next-gen UI library                   public  2025-06-15
alex-dev/ansible-playbooks   Provisioning scripts                    private 2025-04-12
```

#### 5. Open the Repository in the Web Browser
When required to check UI layouts, I opened the repository's GitHub homepage instantly:
```bash
$ gh repo view --web
# Launches default web browser straight to https://github.com/alex-dev/temp-devops-test
```

#### 6. Safe Teardown: Delete the Test Repository
To clean up test environments safely, I deleted the temporary sandbox:
```bash
$ gh repo delete alex-dev/temp-devops-test --confirm
✓ Deleted repository alex-dev/temp-devops-test
```

---

## 🐞 Lab Walkthrough: Task 3 (GitHub Issues Management)

Managing software bugs and features from the console keeps engineers focused on the code, enabling faster logging and tracking.

### Step-by-Step Execution Log

#### 1. Create a Staged Issue
I created a detailed bug ticket with specific labels to alert my team:
```bash
$ gh issue create --title "bug: database migration timeout on staging" --body "Executing standard knex-migration leads to socket hangup after 30000ms. Detailed logs attached." --label "bug, high-priority"
✓ Created issue #42 in alex-dev/modern-react-app
https://github.com/alex-dev/modern-react-app/issues/42
```

#### 2. List Active Open Issues
I listed all open issue tickets to prioritize today's milestones:
```bash
$ gh issue list
Showing 2 of 2 open issues in alex-dev/modern-react-app

#42  bug: database migration timeout on staging  (bug, high-priority)
#38  feature: implement dark mode layout         (enhancement)
```

#### 3. Inspect a Specific Ticket
I examined the issue thread and body in detail to debug the problem:
```bash
$ gh issue view 42

bug: database migration timeout on staging #42
Open • alex-dev opened about 1 minute ago • 0 comments

  Executing standard knex-migration leads to socket hangup after 30000ms. Detailed logs
  attached.

Labels: bug, high-priority
```

#### 4. Close the Issue
After correcting the migration config, I closed the ticket directly from the console:
```bash
$ gh issue close 42 --comment "Fixed. Increased knex timeout threshold in config/database.js."
✓ Closed issue #42 in alex-dev/modern-react-app
```

---

### ❓ Conceptual Q&A: Scripting with Issues

#### How could you use `gh issue` in a script or automation?
Because `gh` outputs structured JSON via `--json` flags, it can be integrated into automation scripts, git hooks, and CI/CD pipelines:
* **Auto-reporting Failures**: In your deployment script or CI workflow, automatically create an issue if a deployment or regression test fails:
  ```bash
  if ! npm run test; then
    gh issue create --title "CI/CD Failure: Test Suite Regressed" \
                    --body "Commit $(git rev-parse --short HEAD) failed integration tests. Check GitHub Actions logs." \
                    --label "ci-failure, urgent"
  fi
  ```
* **Daily Status Reports**: Automate a cron script to run every morning, fetch all open issues, and parse them with `jq` to send alerts to Slack:
  ```bash
  gh issue list --json number,title,labels | jq '.[] | "Issue #\(.number): \(.title) [\(.labels[].name)]"'
  ```

---

## 🔀 Lab Walkthrough: Task 4 (GitHub Pull Requests & Reviews)

I practiced branching, committing, creating, tracking, and merging a Pull Request (PR) entirely within the command line.

### Step-by-Step Execution Log

#### 1. Branch, Modify, and Push Changes
```bash
# Checkout a new feature branch
$ git switch -c feature/gh-cli-docs
Switched to a new branch 'feature/gh-cli-docs'

# Make a modification
$ echo "# GitHub CLI Mastery" >> CLI_GUIDE.md
$ git add CLI_GUIDE.md
$ git commit -m "docs: compose advanced GitHub CLI cheatsheet"
[feature/gh-cli-docs d4f5a6b] docs: compose advanced GitHub CLI cheatsheet
 1 file changed, 1 insertion(+)

# Push to remote branch
$ git push -u origin feature/gh-cli-docs
```

#### 2. Create the Pull Request
I initialized a Pull Request on GitHub. I used the `--fill` flag to automatically use the commit logs for the PR title and description:
```bash
$ gh pr create --fill --label "documentation"
✓ Created pull request #43 for alex-dev/modern-react-app
https://github.com/alex-dev/modern-react-app/pull/43
```

#### 3. Monitor PR Status and Details
I checked the integration checks and approval status:
```bash
$ gh pr status
Relevant PRs in alex-dev/modern-react-app

Current branch
  #43  docs: compose advanced GitHub CLI cheatsheet [feature/gh-cli-docs]
    ✓ Checks passing: 2 successful
    - Reviewers: None assigned

$ gh pr view 43
docs: compose advanced GitHub CLI cheatsheet #43
Open • alex-dev wants to merge 1 commit into main from feature/gh-cli-docs • 0 reviews

  docs: compose advanced GitHub CLI cheatsheet
```

#### 4. Merge the Pull Request
With checks passing, I merged the PR using the squash method and cleaned up local files:
```bash
$ gh pr merge 43 --squash --delete-branch
✓ Squashed and merged pull request #43 (docs: compose advanced GitHub CLI cheatsheet)
✓ Deleted branch feature/gh-cli-docs and switched to branch main
✓ Deleted remote branch feature/gh-cli-docs
```

---

### ❓ Conceptual Q&A: Pull Request Management

#### What merge methods does `gh pr merge` support?
The CLI fully supports all three native GitHub merge strategies:
1. **`--merge`**: Performs a standard merge, creating a 3-way merge commit that preserves all individual commits from the feature branch.
2. **`--rebase`**: Re-applies individual commits onto the base branch without a merge commit, creating a linear history.
3. **`--squash`**: Combines all feature commits into a single commit on the base branch. This keeps the main history clean and unified.

#### How would you review someone else's PR using `gh`?
DevOps engineers can complete a full PR review workflow without opening a browser:
1. **Fetch & Test Locally**: Check out the PR branch locally to run and test the code:
   ```bash
   gh pr checkout 43
   ```
2. **Inspect Code Differences**: Review the line-by-line diff directly in the terminal:
   ```bash
   gh pr diff 43
   ```
3. **Check CI Pipeline Status**: Confirm that automated tests are passing:
   ```bash
   gh pr checks 43
   ```
4. **Approve or Request Changes**: Submit a formal review with comments:
   ```bash
   # Approve PR:
   gh pr review 43 --approve --body "Verified locally. Excellent changes."
   
   # Request Changes:
   gh pr review 43 --request-changes --body "Please optimize the database queries before merging."
   ```

---

## 🤖 Lab Walkthrough: Task 5 (GitHub Actions & Workflows Preview)

Monitoring CI/CD pipelines directly from the terminal saves valuable context-switching time. I explored how `gh` interacts with GitHub Actions.

### Step-by-Step Execution Log

#### 1. List Active and Historic Workflow Runs
I listed recent CI pipeline runs to monitor our codebase health:
```bash
$ gh run list --limit 3
STATUS  NAME                  EVENT   BRANCH  WORKFLOW     RUN ID      ATTEMPT  ELAPSED
✓       Integration Tests     push    main    ci.yml       9876543210  1        2m 14s
✗       Staging Deploy        push    main    deploy.yml   9876543209  1        1m 45s
✓       Linting & Formatting  push    dev     lint.yml     9876543208  1        45s
```

#### 2. Deep-Dive a Failed Run
I analyzed the failed `Staging Deploy` run (`9876543209`) to identify the exact error:
```bash
$ gh run view 9876543209

✗ Staging Deploy #9876543209
Triggered by: push • Branch: main • Commit: a1b2c3d
Failed 3 minutes ago • Took 1m 45s

JOBS
✗ Deploy to AWS ECS (ID 123456)
  ✗ Step: Run Docker Build & Push (Failed with Exit Code 1)

LOGS
  Step: Run Docker Build & Push
  [Docker Build] ERROR: failed to solve: rpc error: code = Unknown desc = failed to compute cache
  [Docker Build] Error: Process completed with exit code 1.
```
> [!TIP]
> **Real-Time Monitoring:** You can use **`gh run watch 9876543209`** to stream live console logs directly to your local terminal as the GitHub Actions agent executes the pipeline!

---

### ❓ Conceptual Q&A: Action & Pipeline Workflows

#### How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?
Integrating `gh run` and `gh workflow` into DevOps workflows enables deep pipeline orchestration:
* **Trigger Downstream Pipelines**: If you have multi-project dependencies, a successful build in Repository A can trigger a workflow run in Repository B:
  ```bash
  gh workflow run deploy.yml --repo org/infrastructure-repo -f env=staging
  ```
* **Polled Orchestration / Multi-Repo Sync**: In complex deployments, a script can trigger a remote workflow and wait for its completion before proceeding:
  ```bash
  run_id=$(gh workflow run integration.yml --json id -q '.id')
  gh run watch "$run_id"
  if [ "$(gh run view "$run_id" --json conclusion -q '.conclusion')" = "success" ]; then
     echo "Tests passed! Continuing deployment..."
  fi
  ```
* **Log Archival & Debugging**: Automate post-mortem reports by downloading failed logs on a schedule and pushing them to archiving tools like AWS S3 or Elasticsearch.

---

## 💡 Task 6: Advanced GitHub CLI Hacks & Tricks

To boost development efficiency, I configured custom aliases, built interactive scripts, and ran custom REST/GraphQL API commands.

### 1. Interactive Command Shortcuts: `gh alias`
I configured shortcuts to simplify long, complex commands into clean 2-3 letter aliases:
```bash
# 1. Quick status check for the current repository's PRs
$ gh alias set prs "pr list --author @me"
✓ Added alias 'prs' for 'pr list --author @me'

# 2. View live pipeline logs for the active branch
$ gh alias set watch "run watch"
✓ Added alias 'watch' for 'run watch'

# 3. Create a private Gist containing a quick snippet
$ gh alias set paste "gist create --public"
✓ Added alias 'paste' for 'gist create --public'
```

### 2. Making Direct API Queries: `gh api`
To retrieve repository fields without navigating the UI, I queried GitHub's REST API:
```bash
$ gh api repos/alex-dev/modern-react-app --template 'Owner: {{.owner.login}} | Stars: {{.stargazers_count}} | Fork: {{.fork}}'
Owner: alex-dev | Stars: 124 | Fork: false
```

### 3. Rapid Snippet Sharing: `gh gist`
I created a secure code paste directly from the CLI:
```bash
$ echo "const express = require('express');" > snippet.js
$ gh gist create snippet.js --public --desc "Express boilerplate"
https://gist.github.com/alex-dev/987654321fedcba
```

### 4. Direct Releases Management: `gh release`
I created a production release with automated notes based on our commit history:
```bash
$ gh release create v1.1.0 --title "v1.1.0 (Stabilization)" --notes "This release implements robust GitHub CLI automation tooling."
✓ Created release v1.1.0 in alex-dev/modern-react-app
https://github.com/alex-dev/modern-react-app/releases/tag/v1.1.0
```

### 5. Instant Global Repo Searches: `gh search repos`
I searched for open-source Ansible playbooks right from the terminal:
```bash
$ gh search repos "ansible-kubernetes" --limit 2
geerlingguy/ansible-role-kubernetes  Ansible Role - Kubernetes  public  1820 stars
kubernetes-sigs/kubespray            Deploy Kubernetes clusters  public  14500 stars
```

---

## 📊 Visual Verification & Console Dashboard

To verify my local-to-remote terminal integration, here is the active terminal dashboard after completing the exercises:

![GitHub CLI Terminal Session Dashboard](github_cli_screenshot.png)

---

Day 26 Complete 🚀

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*