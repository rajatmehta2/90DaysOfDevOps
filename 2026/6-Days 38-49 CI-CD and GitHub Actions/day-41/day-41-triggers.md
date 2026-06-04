# Day 41: GitHub Actions Triggers & Matrix Builds ⚡

Welcome to **Day 41 of the 90 Days of DevOps Challenge!** Today, we are taking our GitHub Actions knowledge to a professional production level. 

In [Day 40](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-40/day-40-first-workflow.md), we constructed a basic pipeline that triggered on a simple code push. Today, we will explore the **entire spectrum of workflow triggers**—learning how to validate code during Pull Requests, automate tasks via scheduled cron jobs, run on-demand pipelines with manual inputs, and leverage **Matrix Builds** to execute multi-environment test suites in parallel.

---

## 🏗️ Task 1: Trigger on Pull Request (PR Validation)

In a professional development team, code is rarely pushed directly to the `main` branch. Instead, developers open a Pull Request (PR), which must trigger automated checks (linting, tests) before a merge is permitted.

Let's create a dedicated workflow that runs checks exclusively on PR events targeting our `main` branch.

### 1. Create the PR Check Workflow File
Inside your local `github-actions-practice` repository, create a new workflow file:

```bash
touch .github/workflows/pr-check.yml
```

### 2. Configure the Pipeline Code
Open `.github/workflows/pr-check.yml` and add the following configuration:

```yaml
name: PR Verification Check

# 1. Trigger the workflow ONLY on PR events (opened or updated) against main
on:
  pull_request:
    branches:
      - main
    types: [opened, synchronize]

jobs:
  pr-validation:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Check out the PR branch code
      - name: Checkout Code
        uses: actions/checkout@v4

      # Step 2: Print branch info using Head Reference (the source branch)
      - name: Print Triggering Branch Name
        run: |
          echo "PR check running for branch: ${{ github.head_ref }}"
          echo "Target branch: ${{ github.base_ref }}"
```

### 3. Create a Feature Branch and Push to Trigger the PR
To verify this trigger, we must push code to a non-main branch and open a PR:

```bash
# Create and switch to a new feature branch
git checkout -b feature/pr-trigger

# Add files and commit
git add .github/workflows/pr-check.yml
git commit -m "feat: add PR verification pipeline"

# Push the new branch to origin
git push origin feature/pr-trigger
```

#### Mock Terminal Output:
```text
$ git checkout -b feature/pr-trigger
Switched to a new branch 'feature/pr-trigger'

$ git add .github/workflows/pr-check.yml
$ git commit -m "feat: add PR verification pipeline"
[feature/pr-trigger 8f5b3a2] feat: add PR verification pipeline
 1 file changed, 23 insertions(+)
 create mode 100644 .github/workflows/pr-check.yml

$ git push origin feature/pr-trigger
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 10 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 464 bytes | 464.00 KiB/s, done.
Total 4 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/toucanrajat/github-actions-practice.git
 * [new branch]      feature/pr-trigger -> feature/pr-trigger
```

Once pushed, navigate to GitHub and open a Pull Request from `feature/pr-trigger` into `main`. The `PR Verification Check` will automatically start running!

### 4. Verification Screenshot
You will see the pipeline check running directly on the Pull Request interface:

![PR Check Running on Pull Request](day41-pr-check.png)

---

## 📅 Task 2: Scheduled Trigger (Cron Syntax)

Scheduled triggers allow us to automate recurring operations, such as nightly integration tests, daily security scans, or system backups.

### 1. Add Scheduled Cron Trigger
We can add a `schedule` block to a new or existing workflow. The syntax uses standard **POSIX cron syntax** with 5 fields:
`MIN HOUR DOM MON DOW` (Minute, Hour, Day of Month, Month, Day of Week).

Here is a snippet showing how to configure a job to run **every day at midnight UTC**:

```yaml
name: Scheduled Nightly Cleanup

on:
  schedule:
    # Run every day at midnight UTC (00:00)
    - cron: '0 0 * * *'

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Perform Maintenance Tasks
        run: |
          echo "Running midnight maintenance and cleanup tasks..."
          echo "Current time: $(date)"
```

> [!IMPORTANT]
> **GitHub Actions Cron Gotchas:**
> 1. Scheduled workflows run in the context of the **default branch** (usually `main`).
> 2. All cron expressions represent **UTC time**. You must calculate offsets manually for your local timezone.
> 3. Due to GitHub runner availability, scheduled jobs can sometimes be delayed up to a few minutes.

### 📝 DevOps Interview Questions & Explanations

#### **Q: What is the cron expression to run every Monday at 9 AM?**
* **Answer:** `0 9 * * 1` (or `0 9 * * MON`)

#### **Cron Syntax Cheat Sheet**
| Field | Meaning | Allowed Values |
| :--- | :--- | :--- |
| **`0`** | Minute | `0 - 59` |
| **`9`** | Hour | `0 - 23` |
| **`*`** | Day of Month | `1 - 31` (any day) |
| **`*`** | Month | `1 - 12` (any month) |
| **`1`** | Day of Week | `0 - 6` (0 = Sunday, 1 = Monday) or abbreviations (`SUN-SAT`) |

---

## 🎛️ Task 3: Manual Trigger (Workflow Dispatch)

Sometimes we need the control to trigger pipelines manually on-demand—like deploying to a specific environment, running manual data recovery scripts, or triggering a release tag build. This is accomplished using `workflow_dispatch`.

### 1. Create the Manual Workflow
Create a new file named `manual.yml` in `.github/workflows/`:

```bash
touch .github/workflows/manual.yml
```

### 2. Configure Manual Trigger with Inputs
Paste the following YAML into `.github/workflows/manual.yml`. This defines a pipeline that asks the operator to select a target environment (`staging` or `production`):

```yaml
name: Manual Deployment

# 1. Enable manual execution from the GitHub Actions UI
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target Deployment Environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
      reason:
        description: 'Reason for deployment'
        required: false
        default: 'Regular release update'
        type: string

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Deploy Infrastructure
        run: |
          echo "Initiating manual deployment..."
          echo "Target Environment: ${{ github.event.inputs.environment }}"
          echo "Triggered by: ${{ github.actor }}"
          echo "Reason given: ${{ github.event.inputs.reason }}"
```

### 3. Commit and Push to Enable manual trigger
```bash
git add .github/workflows/manual.yml
git commit -m "feat: add manual deployment workflow with inputs"
git push origin main
```

### 4. Triggering the Workflow from UI
1. Navigate to your repository's **Actions** tab.
2. Select **Manual Deployment** in the left sidebar.
3. Click the **Run workflow** dropdown on the right side.
4. Select the branch, choose the environment (`staging` or `production`), and type a reason.
5. Click the green **Run workflow** button!

#### Mock Executed Steps Output:
```text
================== Step: Deploy Infrastructure ==================
Initiating manual deployment...
Target Environment: production
Triggered by: toucanrajat
Reason given: Out-of-band hotfix deployment
```

### 5. Verification Screenshot
Here is the interactive form shown in the GitHub web interface:

![Manual Run Workflow Interface](day41-manual-dispatch.png)

---

## 🤖 Task 4: Matrix Builds (Parallel Job Execution)

One of the most powerful features of GitHub Actions is the **Matrix Build**. Instead of duplicating configuration files to test multiple versions of a runtime or various operating systems, a matrix lets you define variables, and GitHub Actions automatically instantiates parallel jobs for each combination.

### 1. Create the Matrix Workflow File
```bash
touch .github/workflows/matrix.yml
```

### 2. Configure Matrix Across Runtimes and OS Environments
Paste the following advanced configuration. This runs our checks across **3 different Python versions** (`3.10`, `3.11`, `3.12`) and **2 distinct Operating Systems** (`ubuntu-latest`, `windows-latest`):

```yaml
name: Multi-Environment Matrix Build

on:
  push:
    branches:
      - main

jobs:
  test:
    name: Test (Python ${{ matrix.python-version }} on ${{ matrix.os }})
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
        os: [ubuntu-latest, windows-latest]
        
    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Validate Python Version
        run: |
          python --version
          echo "Successfully validated Python ${{ matrix.python-version }} on ${{ matrix.os }}"
```

### 📝 Matrix Scalability Question & Answer
**Q: When we extend the matrix to include 3 Python versions and 2 Operating Systems, how many total jobs run?**
* **Answer:** **6 jobs** run in parallel!
* **Calculation:** `3 (Python versions) * 2 (Operating Systems) = 6 execution permutations`.

#### Parallel Execution Visual:
```text
                       ┌──► [Python 3.10 on Ubuntu] (Job 1)
                       ├──► [Python 3.11 on Ubuntu] (Job 2)
                       ├──► [Python 3.12 on Ubuntu] (Job 3)
[Push to main] ───────┼──► [Python 3.10 on Windows] (Job 4)
                       ├──► [Python 3.11 on Windows] (Job 5)
                       └──► [Python 3.12 on Windows] (Job 6)
```

---

## ❌ Task 5: Matrix Exclusions & Fail-Fast Strategy

In advanced CI/CD setups, we need mechanisms to fine-tune matrix builds—excluding incompatible environments or preventing resource wastage if a core test suite fails early.

### 1. Excluding Specific Matrix Combinations
Some runtime versions might be incompatible with specific operating systems. Instead of splitting the matrix, we use the `exclude` directive.

Let's modify our workflow to **exclude** Python `3.10` running on `windows-latest`.

### 2. Configuring the Fail-Fast Strategy
* **`fail-fast: true` (Default):** If any single job in the matrix fails, GitHub Actions instantly cancels all other currently running or queued jobs in that matrix. This is excellent for saving build time and runner minutes.
* **`fail-fast: false`:** If a job fails, the remaining jobs in the matrix continue running to completion anyway. This is crucial when you need to gather a complete diagnostic report across all platforms, regardless of failures in specific configurations.

### 3. Integrated Advanced Matrix Configuration
Here is the fully refined `.github/workflows/matrix.yml` demonstrating both `exclude` and `fail-fast: false`:

```yaml
name: Advanced Matrix Build

on:
  push:
    branches:
      - main

jobs:
  test:
    name: Run Checks (Py-${{ matrix.python-version }} / ${{ matrix.os }})
    strategy:
      # Prevent a failure in one job from terminating the other running jobs
      fail-fast: false
      
      matrix:
        python-version: ['3.10', '3.11', '3.12']
        os: [ubuntu-latest, windows-latest]
        
        # Exclude Python 3.10 on Windows
        exclude:
          - os: windows-latest
            python-version: '3.10'

    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Configuration details
        run: |
          python --version
          echo "OS Environment: ${{ matrix.os }}"
          echo "Python version: ${{ matrix.python-version }}"

      # Simulate a mock error ONLY for Ubuntu with Python 3.12 to prove fail-fast behavior
      - name: Simulate Intentional Testing Error
        if: ${{ matrix.python-version == '3.12' && matrix.os == 'ubuntu-latest' }}
        run: |
          echo "ERROR: Intentionally failing test suite to test fail-fast: false"
          exit 1
```

### 4. Verification Output analysis
With the `exclude` block active, only **5 jobs** are queued (Windows + Python 3.10 is removed):
1. `ubuntu-latest` + `3.10`
2. `ubuntu-latest` + `3.11`
3. `ubuntu-latest` + `3.12`
4. `windows-latest` + `3.11`
5. `windows-latest` + `3.12`

When the Ubuntu + Python 3.12 job encounters the simulated exit code `1`, it fails. However, because we configured `fail-fast: false`, the remaining 4 jobs continue executing and successfully complete with green checkmarks!

### 5. Verification Screenshot
Here is the visual proof showing the failed job highlighted while the others continue unimpeded:

![Matrix Execution with fail-fast disabled](day41-matrix-parallel.png)

---

## 💡 Key Takeaways for Day 41

* **Trigger Variety:** Workflow automation can be triggered by pull requests, specific timers (`schedule`), and even directly through interactive UI prompts (`workflow_dispatch`).
* **Cron Timezones:** GitHub Actions runs scheduled tasks strictly in **UTC time**. Keep this in mind when scheduling production jobs.
* **Matrix Power:** Multi-dimensional matrix builds multiply runtimes by systems, allowing enormous test suites to run parallelly with minimal YAML code.
* **Exclude & Fail-Fast Control:** `exclude` lets you filter out invalid environments, and setting `fail-fast: false` guarantees that one OS failure doesn't swallow valuable test feedback from other platforms.

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*