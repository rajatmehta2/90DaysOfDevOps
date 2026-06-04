# Day 47: Advanced Event Triggers: PR Lifecycles, Cron Schedules & Event-Driven Pipelines 🚀

Welcome to Day 47 of the **90 Days of DevOps** journey! Today, we transition from simple `push` triggers to production-grade automation. GitHub Actions supports a vast range of event triggers that allow you to construct complex, automated gates, orchestrate multi-pipeline deployments, trigger scheduled background processes, and integrate external applications.

In this guide, we dive deep into advanced event triggers: Pull Request lifecycles, automated PR gates, scheduled Cron schedules, smart path and branch filters, workflow chaining (`workflow_run`), and external triggers (`repository_dispatch`).

---

## 📋 Table of Contents
1. [Task 1: Pull Request Event Lifecycle Types](#-task 1-pull-request-event-lifecycle-types)
2. [Task 2: Creating Automated PR Quality Gates](#-task 2-creating-automated-pr-quality-gates)
3. [Task 3: Scheduled Workflows (Cron Schedules Deep Dive)](#-task-3-scheduled-workflows-cron-schedules-deep-dive)
4. [Task 4: Smart Filters (Path & Branch Filtering)](#-task-4-smart-filters-path--branch-filtering)
5. [Task 5: Workflow Chaining (`workflow_run` vs `workflow_call`)](#-task-5-workflow-chaining-workflow_run-vs-workflow_call)
6. [Task 6: External Event Triggers (`repository_dispatch`)](#-task-6-external-event-triggers-repository_dispatch)
7. [🛠️ Git Commands & Local Verification](#%EF%B8%8F-git-commands--local-verification)
8. [🖼️ Execution Visualizations](#%EF%B8%8F-execution-visualizations)
9. [💡 Summary & Takeaways](#-summary--takeaways)

---

## 📘 Task 1: Pull Request Event Lifecycle Types

The standard `pull_request` event triggers a workflow whenever a PR is created or updated. However, a pull request is a living document with a rich lifecycle. By specifying **activity types**, you can trigger targeted workflows at precise moments.

### The Lifecycle Workflow: `.github/workflows/pr-lifecycle.yml`
This workflow monitors critical PR actions—`opened` (PR is created), `synchronize` (new commits are pushed), `reopened` (a closed PR is revived), and `closed` (PR is closed or merged). It logs context metadata and runs a conditional task if the PR was successfully merged.

```yaml
name: PR Event Lifecycle Logger

on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
      - closed

jobs:
  log-pr-details:
    name: Log PR Context
    runs-on: ubuntu-latest
    steps:
      - name: Output PR Metadata
        run: |
          echo "=================================================="
          echo "📥 PR EVENT ACTIVATED"
          echo "👉 Action Type   : ${{ github.event.action }}"
          echo "📝 PR Title      : ${{ github.event.pull_request.title }}"
          echo "👤 PR Author     : ${{ github.event.pull_request.user.login }}"
          echo "🌿 Source Branch : ${{ github.event.pull_request.head.ref }}"
          echo "🎯 Target Branch : ${{ github.event.pull_request.base.ref }}"
          echo "=================================================="

      - name: Handle PR Merged Event
        if: github.event.pull_request.merged == true
        run: |
          echo "🎉 SUCCESS: The Pull Request has been merged into ${{ github.event.pull_request.base.ref }}!"
          echo "🚀 Initiating cleanup or post-merge logging..."
```

> [!NOTE]
> The conditional expression `github.event.pull_request.merged == true` is checked during the `closed` activity type to verify if the closure was a result of a merge or a manual close without merging.

---

## 🛡️ Task 2: Creating Automated PR Quality Gates

PR validation workflows act as automated gatekeepers, ensuring that incoming code adheres to organizational policies, branch naming structures, and file size limits before a review even begins.

### The Validation Workflow: `.github/workflows/pr-checks.yml`
This workflow runs on any PR targeting the `main` branch. It hosts three parallel jobs to enforce strict quality gates:
1. **`file-size-check`**: Scans the workspace and fails if any individual file exceeds 1 MB.
2. **`branch-name-check`**: Scans the head branch name and fails if it does not follow naming conventions (`feature/*`, `fix/*`, `docs/*`).
3. **`pr-body-check`**: Warns the developers if the PR description has been left empty but doesn't fail the pipeline.

```yaml
name: PR Validation Gatekeeper

on:
  pull_request:
    branches:
      - main

jobs:
  file-size-check:
    name: Check File Sizes
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Scan for Files Exceeding 1MB
        run: |
          echo "🔍 Scanning codebase for files larger than 1MB (excluding .git folder)..."
          LARGE_FILES=$(find . -not -path '*/.*' -type f -size +1M)
          if [ -n "$LARGE_FILES" ]; then
            echo "❌ CRITICAL: The following files exceed the 1MB file size limit:"
            echo "$LARGE_FILES"
            exit 1
          else
            echo "✅ SUCCESS: All files are within acceptable limits (< 1MB)."
          fi

  branch-name-check:
    name: Verify Branch Naming Convention
    runs-on: ubuntu-latest
    steps:
      - name: Validate Head Branch Name
        run: |
          BRANCH_NAME="${{ github.head_ref }}"
          echo "🌿 Checking branch name: $BRANCH_NAME"
          
          # Match feature/*, fix/*, or docs/*
          if [[ "$BRANCH_NAME" =~ ^(feature/|fix/|docs/) ]]; then
            echo "✅ SUCCESS: Branch name '$BRANCH_NAME' follows standards!"
          else
            echo "❌ CRITICAL: Branch name '$BRANCH_NAME' is non-compliant."
            echo "💡 Please rename your branch to match pattern: feature/*, fix/*, or docs/*"
            exit 1
          fi

  pr-body-check:
    name: Check PR Description Content
    runs-on: ubuntu-latest
    steps:
      - name: Scan PR Body Description
        run: |
          PR_BODY="${{ github.event.pull_request.body }}"
          echo "📝 Inspecting Pull Request body/description..."
          if [ -z "$PR_BODY" ]; then
            echo "⚠️ WARNING: PR description is blank!"
            echo "💡 It is highly recommended to describe changes to help reviewers."
          else
            echo "✅ SUCCESS: PR description is populated with context."
          fi
```

---

## ⏰ Task 3: Scheduled Workflows (Cron Schedules Deep Dive)

Scheduled workflows allow you to automate routine maintenance tasks, such as triggering nightly builds, performing security scans, or checking the health of public facing endpoints.

### The Scheduled Workflow: `.github/workflows/scheduled-tasks.yml`
This workflow runs on two schedule cycles and can also be triggered manually using `workflow_dispatch`. It performs an automated curl-based health check on a server endpoint.

```yaml
name: Scheduled Health Monitor

on:
  schedule:
    - cron: '30 2 * * 1'   # Every Monday at 02:30 AM UTC
    - cron: '0 */6 * * *'  # Every 6 hours (00:00, 06:00, 12:00, 18:00 UTC)
  workflow_dispatch:        # Enable manual executions

jobs:
  health-check:
    name: API & Platform Health Check
    runs-on: ubuntu-latest
    steps:
      - name: Log Cron Trigger Context
        run: |
          echo "=================================================="
          echo "🔔 HEALTH CHECK WORKFLOW TRIGGERED"
          echo "📅 Timestamp     : $(date -u) UTC"
          echo "⚡ Event Trigger : ${{ github.event_name }}"
          if [ "${{ github.event_name }}" = "schedule" ]; then
            echo "⏰ Triggered by Schedule (Cron Expression): ${{ github.event.schedule }}"
          else
            echo "👤 Triggered Manually via Workflow Dispatch"
          fi
          echo "=================================================="

      - name: Execute Endpoint Health Check
        run: |
          echo "📡 Testing public endpoint connectivity..."
          RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://httpbin.org/status/200)
          echo "👉 Server returned response status: $RESPONSE_CODE"
          
          if [ "$RESPONSE_CODE" -eq 200 ]; then
            echo "✅ SUCCESS: Endpoint is active and returning healthy 200 status!"
          else
            echo "❌ CRITICAL: Endpoint returned unhealthy status code: $RESPONSE_CODE"
            exit 1
          fi
```

### 🧠 Cron Schedules Q&A

1. **What is the cron expression for every weekday at 9 AM IST?**
   * **IST to UTC Conversion:** Indian Standard Time (IST) is UTC + 5:30. To get 9:00 AM IST in UTC, we subtract 5 hours and 30 minutes.
     * `9:00 AM - 5h 30m = 3:30 AM UTC`.
   * **Weekdays:** Monday to Friday (`1-5`).
   * **Cron Expression:** **`'30 3 * * 1-5'`**

2. **What is the cron expression for the first day of every month at midnight UTC?**
   * **Details:** Minute: `0`, Hour: `0`, Day of Month: `1`, Month: `*`, Day of Week: `*`.
   * **Cron Expression:** **`'0 0 1 * *'`**

3. **Why does GitHub state that scheduled workflows may be delayed or skipped on inactive repos?**
   * **Resource Allocation:** To optimize global resources, GitHub automatically suspends schedules on repositories that have experienced no commits or activity for 60 consecutive days. 
   * **Queueing Delays:** GitHub Actions running on `schedule` are scheduled, but they are not guaranteed to run precisely at the minute specified. High infrastructure demands and job queuing can result in delays ranging from minutes to hours.

---

## 🎯 Task 4: Smart Filters (Path & Branch Filtering)

To optimize runner minutes and maintain fast feedback loops, you should prevent workflows from running on changes that don't affect compiling/running code (e.g., changes to documentation).

### Smart Path Filters: `.github/workflows/smart-triggers-paths.yml`
This workflow triggers **only** when files inside `src/` or `app/` are added/modified, on `main` and release branches.

```yaml
name: Path-Inclusion CI Pipeline

on:
  push:
    branches:
      - main
      - 'release/*'
    paths:
      - 'src/**'
      - 'app/**'

jobs:
  build-and-test:
    name: Build Filtered Application
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v4

      - name: Run Focused Build Pipeline
        run: |
          echo "📦 Smart triggers verified!"
          echo "🚀 Processing application builds for changes detected in src/ or app/..."
```

### Smart Path Ignore: `.github/workflows/smart-triggers-ignore.yml`
This workflow runs on all commits, **except** when the changes only involve markdown files (`.md`) or documentation directories.

```yaml
name: Global Code CI Pipeline

on:
  push:
    branches:
      - main
      - 'release/*'
    paths-ignore:
      - '*.md'
      - 'docs/**'

jobs:
  code-lint:
    name: Execute Code Linters
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v4

      - name: Lint Verification
        run: |
          echo "🔍 Code-based changes detected. Running lints..."
```

### ❓ When to use `paths` vs `paths-ignore`?

| Option | When to use | Example |
| :--- | :--- | :--- |
| **`paths`** | Use when a workflow only applies to **specific parts** of a repository. Highly recommended in **monorepos** or multi-service codebases (e.g., frontend pipeline only watches `frontend/**`). | Build/Deploy actions, microservice testing. |
| **`paths-ignore`** | Use when a workflow must run for almost **every change**, except for cosmetic or document updates that require zero code compilation/testing. | General styling lints, static page checkers, or basic code verification. |

> [!IMPORTANT]
> You cannot combine `paths` and `paths-ignore` for the same event trigger inside a single workflow. If both are specified, the workflow will ignore `paths-ignore`.

---

## ⛓️ Task 5: Workflow Chaining (`workflow_run` vs `workflow_call`)

Chaining workflows together enables you to create complex event-driven pipelines where one workflow starts immediately upon the successful completion of another.

### 1. The Parent Testing Suite: `.github/workflows/tests.yml`
This runs standard code checks and lint runs on every push.

```yaml
name: Run Tests

on:
  push:
    branches:
      - main

jobs:
  run-unit-tests:
    name: Execution of Test Suite
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Execute Test Framework
        run: |
          echo "🧪 Initializing testing run..."
          echo "✅ All unit, integration, and security checks passed successfully!"
```

### 2. The Chained Deployment Pipeline: `.github/workflows/deploy-after-tests.yml`
This workflow is triggered automatically **only after** the `Run Tests` workflow completes. It includes a conditional gate to block execution if the test run failed.

```yaml
name: Post-Test CD Deployment

on:
  workflow_run:
    workflows: ["Run Tests"]
    types:
      - completed

jobs:
  deploy-pipeline:
    name: Deploy to Production
    runs-on: ubuntu-latest
    steps:
      - name: Output Workflow Metadata
        run: |
          echo "🏁 Triggered by Workflow: ${{ github.event.workflow_run.name }}"
          echo "📊 Parent Execution Status: ${{ github.event.workflow_run.conclusion }}"

      - name: Check Parent Build Success
        if: ${{ github.event.workflow_run.conclusion == 'success' }}
        run: |
          echo "=================================================="
          echo "🚀 Parent tests successfully completed! Starting CD pipeline..."
          echo "🐳 Pulling stable Docker builds..."
          echo "☸️ Performing Rolling Update to Kubernetes cluster..."
          echo "✅ SUCCESS: Environment deployed successfully!"
          echo "=================================================="

      - name: Handle Parent Build Failure
        if: ${{ github.event.workflow_run.conclusion != 'success' }}
        run: |
          echo "=================================================="
          echo "❌ CRITICAL: Parent test run failed or aborted!"
          echo "⚠️ Deployment is blocked. Exiting workflow run."
          echo "=================================================="
          exit 1
```

### 📊 Comparison: `workflow_run` vs `workflow_call`

| Feature | `workflow_run` (Workflow Chaining) | `workflow_call` (Reusable Workflows) |
| :--- | :--- | :--- |
| **Execution Mode** | **Asynchronous / Decoupled:** Triggered after the parent workflow finishes. | **Synchronous / Nested:** Embedded directly inside the caller workflow's execution graph. |
| **Trigger Style** | Reacts to the completion event of a named parent workflow. | Explicitly called by a workflow job using the `uses:` keyword. |
| **Data Sharing** | Secrets and inputs are **not** inherited. Data must be retrieved via artifacts. | Inputs and secrets are explicitly passed in from the caller workflow. |
| **UI Representation** | Appears as a completely distinct, standalone workflow run in the dashboard. | Renders as nested job boxes directly inside the caller's dashboard representation. |
| **Use Case** | Chaining unrelated or independent tasks (e.g., triggering a release check only after tests succeed). | Creating modular, standard pipeline templates shared across multiple repositories (DRY principle). |

---

## 🔌 Task 6: External Event Triggers (`repository_dispatch`)

The `repository_dispatch` trigger enables you to trigger GitHub Actions pipelines from external platforms, such as Slack bots, third-party monitoring systems (e.g., Datadog, Prometheus alerts), or headless CMS updates.

### The Dispatch Workflow: `.github/workflows/external-trigger.yml`
This workflow listens for a repository dispatch event with type `deploy-request`. It prints a custom payload sent by the external system.

```yaml
name: Repository Dispatch External Trigger

on:
  repository_dispatch:
    types:
      - deploy-request

jobs:
  external-dispatch-job:
    name: Run External API Dispatch
    runs-on: ubuntu-latest
    steps:
      - name: Process Remote Event Data
        run: |
          echo "=================================================="
          echo "🔗 EXTERNAL WEBHOOK DISPATCH DECRYPTED"
          echo "🤖 Triggered by event_type: ${{ github.event.action }}"
          echo "🌐 Target Environment   : ${{ github.event.client_payload.environment }}"
          echo "👤 Custom Triggered By  : ${{ github.actor }}"
          echo "=================================================="
          echo "🚀 Processing remote request to spin up environment: ${{ github.event.client_payload.environment }}"
```

### 🛰️ Triggering the Event

You can trigger the pipeline by sending a POST request to GitHub's REST API. Ensure your request includes a **GitHub Personal Access Token (PAT)** with appropriate `repo` scopes.

#### Using GitHub CLI (`gh`):
```bash
gh api repos/rajatmehta2/90DaysOfDevOps/dispatches \
  -f event_type=deploy-request \
  -f client_payload='{"environment":"production"}'
```

#### Using standard `curl`:
```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR_PERSONAL_ACCESS_TOKEN>" \
  https://api.github.com/repos/rajatmehta2/90DaysOfDevOps/dispatches \
  -d '{"event_type": "deploy-request", "client_payload": {"environment": "production"}}'
```

### 💡 Real-World Scenarios for External Triggers
- **ChatOps Orchestration:** A team member typing `/deploy production` inside Slack or Discord triggers an API webhook that launches the deployment workflow.
- **Alert-Driven Failover:** A monitoring system (like Prometheus or Datadog) triggers a repository dispatch to run a rollback script or scaling routine upon detecting high crash/latency rates.
- **CMS Content Rebuilds:** A headless CMS (like Strapi, Sanity, or Contentful) triggers a static site rebuild workflow on GitHub whenever a content editor hits "Publish" on a blog post.

---

## 🛠️ Git Commands & Local Verification

To deploy these five workflows, use the following commands to create, stage, commit, and push these definitions to your repository.

```bash
# 1. Ensure you are at the Git repository root
cd /Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps

# 2. Create the workflows directory if it doesn't exist
mkdir -p .github/workflows

# 3. Stage the files for tracking
git add .github/workflows/pr-lifecycle.yml
git add .github/workflows/pr-checks.yml
git add .github/workflows/scheduled-tasks.yml
git add .github/workflows/smart-triggers-paths.yml
git add .github/workflows/smart-triggers-ignore.yml
git add .github/workflows/tests.yml
git add .github/workflows/deploy-after-tests.yml
git add .github/workflows/external-trigger.yml
git add 2026/day-47/day-47-advanced-triggers.md

# 4. Commit changes with a descriptive message
git commit -m "feat: implement advanced triggers, PR gates, scheduled tasks, and chained pipelines"

# 5. Push code safely to main branch
git push origin main
```

### Mock Terminal Output
```text
$ git push origin main
Enumerating objects: 19, done.
Counting objects: 100% (19/19), done.
Delta compression using up to 8 threads
Compressing objects: 100% (16/16), done.
Writing objects: 100% (19/19), 248.12 KiB | 12.41 MiB/s, done.
Total 19 (delta 5), reused 0 (delta 0), pack-reused 0
To github.com:rajatmehta2/90DaysOfDevOps.git
   9c4a8b1..7f3b8a4  main -> main
⚡ Push completed successfully!
🤖 GitHub Actions: Scanned 8 new configurations. Loading event pipelines...
```

---

## 🖼️ Execution Visualizations

When a Pull Request is opened or updated, GitHub executes the automated validation gates. The checks must pass before the branch can be merged, ensuring a high-quality codebase.

Below is a visualization of the quality gates verifying a Pull Request.

![Automated PR Checks Validation Dashboard](pr_checks.png)

---

## 💡 Summary & Takeaways

Today we explored advanced automation workflows:
- **PR Activity Hooks:** Target workflows to execute at specific moments in a PR's lifecycle using activity types (`opened`, `synchronize`, `closed`, `reopened`).
- **Strict Quality Gates:** Enforce automated validation checks on incoming branches (size limits, naming standards, PR context) to maintain repository cleanliness.
- **Background Cron Jobs:** Set up routine maintenance tasks and api health checks using robust schedule expressions.
- **Smart Filtering:** Save runner minutes and minimize queue times by adding `paths` or `paths-ignore` logic.
- **Pipeline Orchestration:** Connect distinct pipelines using `workflow_run` for asynchronous chaining or `workflow_call` for dry modular templates.
- **External API Triggers:** Initiate automated pipelines from external monitoring tools and Slack bots using `repository_dispatch`.

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*