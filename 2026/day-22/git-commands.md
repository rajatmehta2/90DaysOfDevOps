# 📘 Day 22 – Git Commands Reference: Build Your Version Control Backbone

> **"Git is the digital ledger of modern software engineering. It tracks the evolution of code, protects codebase integrity through branching, and acts as the foundational highway for DevOps CI/CD pipelines. Mastering Git commands is the first and most critical step toward seamless infrastructure-as-code and team collaboration."**

Welcome to Day 22 of the **90 Days of DevOps** challenge! This is a clean, production-grade, highly structured **Git Commands Reference Guide**. It has been designed as an instant, zero-friction developer cheat sheet that covers basic repository setup, active file staging, commit orchestration, history log analysis, and system-level version auditing.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Git Version Control System, Global Configuration, Repository Initialization, Staging Mechanisms, Atomic Commits, Log Audits |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Interface** | Git CLI v2.50.x (Apple Git) |
| **Target Document** | [git-commands.md](git-commands.md) |
| **Key Command Interfaces** | `git config`, `git init`, `git status`, `git add`, `git commit`, `git log`, `git diff`, `git show` |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-22/` |

---

## 📑 Table of Contents
1. [📊 Quick Reference Commands Matrix](#-quick-reference-commands-matrix)
2. [⚙️ 1. Setup & Configuration](#️-1-setup--configuration)
3. [🔄 2. Basic Workflow & Staging](#-2-basic-workflow--staging)
4. [🔍 3. Viewing Changes & History](#-3-viewing-changes--history)
5. [🛡️ Git Best Practices for DevOps](#️-git-best-practices-for-devops)
6. [🎨 Visual Reference Dashboard](#-visual-reference-dashboard)

---

## 📊 Quick Reference Commands Matrix

Below is a syntax lookup matrix summarizing core Git operations for daily operations:

| Category | Command Syntax | Description (1 Line Summary) | DevOps Use Case |
| :--- | :--- | :--- | :--- |
| **Setup & Config** | `git config --global user.name "Name"` | Configures the author identity name globally for all repositories. | Attributing codebase authors in public/private repos. |
| **Setup & Config** | `git config --global user.email "email"` | Configures the author identity email globally for all repositories. | Linking commits to GitHub accounts and verification. |
| **Setup & Config** | `git config --list` | Displays all configured variables and settings across all scopes. | Debugging local and global repository environment settings. |
| **Setup & Config** | `git init` | Initializes a new local Git repository, creating the `.git/` folder. | Bootstrapping a new microservice or Terraform workspace. |
| **Basic Workflow** | `git status` | Displays the status of working directory modifications and staged items. | Inspecting current file modifications before staging/committing. |
| **Basic Workflow** | `git add <file>` | Stages specified file changes to index, preparing them for a commit. | Selecting specific files or chunks for the next logical commit. |
| **Basic Workflow** | `git add .` | Stages all changes in the current directory and subdirectories. | Bulk staging file adjustments across larger projects. |
| **Basic Workflow** | `git commit -m "msg"` | Saves staged snapshot into repository history with a custom message. | Logging code changes in permanent history as atomic milestones. |
| **Viewing Changes**| `git log` | Displays the full, chronological commit log of the repository. | Investigating historical development steps and commit details. |
| **Viewing Changes**| `git log --oneline` | Displays commit history in a highly compact, single-line format. | Quick, high-level review of the local commit chain. |
| **Viewing Changes**| `git diff` | Shows differences between the working tree and the staging area index. | Spotting exact code diffs before staging modifications. |
| **Viewing Changes**| `git show <commit>` | Shows the description and content differences of a specific commit. | Conducting code review audits for a specific change event. |

---

## ⚙️ 1. Setup & Configuration

These commands establish your identity and initialize your developer workspace. They are run once per machine setup or once per project initialization.

### A. `git config --global user.name`
* **What it does:** Configures the author identity name globally across all Git repositories on your local computer.
* **Syntax:**
  ```bash
  git config --global user.name "Your Name"
  ```
* **Example Usage:**
  ```bash
  git config --global user.name "rajatmehta2"
  ```
* **Console Output:**
  ```text
  # Command runs silently, writing setting to ~/.gitconfig
  ```

### B. `git config --global user.email`
* **What it does:** Configures the author identity email globally for all local Git repositories on your computer.
* **Syntax:**
  ```bash
  git config --global user.email "your.email@example.com"
  ```
* **Example Usage:**
  ```bash
  git config --global user.email "rajat.mehta2@gmail.com"
  ```
* **Console Output:**
  ```text
  # Command runs silently, writing setting to ~/.gitconfig
  ```

### C. `git config --list`
* **What it does:** Lists all active Git configuration variables and their current values across system, global, and local scopes.
* **Syntax:**
  ```bash
  git config --list
  ```
* **Example Usage:**
  ```bash
  git config --list
  ```
* **Console Output:**
  ```text
  credential.helper=osxkeychain
  user.name=rajatmehta2
  user.email=rajat.mehta2@gmail.com
  core.repositoryformatversion=0
  core.filemode=true
  core.bare=false
  core.logallrefupdates=true
  core.ignorecase=true
  core.precomposeunicode=true
  ```

### D. `git init`
* **What it does:** Initializes an empty local Git repository by creating a hidden `.git/` folder containing necessary version-tracking structures.
* **Syntax:**
  ```bash
  git init
  ```
* **Example Usage:**
  ```bash
  mkdir -p devops-git-practice && cd devops-git-practice
  git init
  ```
* **Console Output:**
  ```text
  Initialized empty Git repository in /Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-22/devops-git-practice/.git/
  ```

---

## 🔄 2. Basic Workflow & Staging

These commands form the core cycle of editing files, staging changes, and committing them to your local database.

### A. `git status`
* **What it does:** Reports the state of your working directory (untracked files, modified files) and the staging area index (staged files).
* **Syntax:**
  ```bash
  git status
  ```
* **Example Usage:**
  ```bash
  git status
  ```
* **Console Output (Empty Repo):**
  ```text
  On branch main

  No commits yet

  nothing to commit (create/copy files and use "git add" to track)
  ```

### B. `git add`
* **What it does:** Takes modified files from the working directory and places them into the staging area (index) to prepare them for the next commit.
* **Syntax:**
  ```bash
  git add <filename>    # Stages a single file
  git add .             # Stages all modified and new files recursively
  ```
* **Example Usage:**
  ```bash
  git add git-commands.md
  ```
* **Console Output:**
  ```text
  # Command runs silently, adding file contents to index objects
  ```

### C. `git commit`
* **What it does:** Records a snapshot of the staged changes in the local repository's history along with a descriptive commit message and author metadata.
* **Syntax:**
  ```bash
  git commit -m "Commit message describing the changes"
  ```
* **Example Usage:**
  ```bash
  git commit -m "feat: initialize git-commands.md with setup & configuration commands"
  ```
* **Console Output:**
  ```text
  [main (root-commit) fefbd32] feat: initialize git-commands.md with setup & configuration commands
   1 file changed, 10 insertions(+)
   create mode 100644 git-commands.md
  ```

---

## 🔍 3. Viewing Changes & History

These commands allow you to look backward in time, inspect your project's commit history, and examine exact file differences.

### A. `git log`
* **What it does:** Displays the chronologically ordered commit history of your active branch, starting from the latest commit.
* **Syntax:**
  ```bash
  git log
  ```
* **Example Usage:**
  ```bash
  git log
  ```
* **Console Output:**
  ```text
  commit dcd989b6574f8818c3b772c5b3648fa7d34190c1 (HEAD -> main)
  Author: rajatmehta2 <rajat.mehta2@gmail.com>
  Date:   Tue Jun 2 14:56:59 2026 +0530

      feat: add viewing changes section (log, diff, show)

  commit 3c9e7e57c6b9074092b76174a8134762cf3cd5b1
  Author: rajatmehta2 <rajat.mehta2@gmail.com>
  Date:   Tue Jun 2 14:56:58 2026 +0530

      feat: document basic workflow commands (add, commit, status)

  commit fefbd32a67bc45df89b9173f671bc97801dfcb65
  Author: rajatmehta2 <rajat.mehta2@gmail.com>
  Date:   Tue Jun 2 14:56:57 2026 +0530

      feat: initialize git-commands.md with setup & configuration commands
  ```

### B. `git log --oneline`
* **What it does:** Summarizes the commit logs in an extremely compact format, displaying only the abbreviated commit hash and the first line of the commit message.
* **Syntax:**
  ```bash
  git log --oneline
  ```
* **Example Usage:**
  ```bash
  git log --oneline
  ```
* **Console Output:**
  ```text
  dcd989b (HEAD -> main) feat: add viewing changes section (log, diff, show)
  3c9e7e5 feat: document basic workflow commands (add, commit, status)
  fefbd32 feat: initialize git-commands.md with setup & configuration commands
  ```

### C. `git diff`
* **What it does:** Compares modifications in the working directory against the current staging area index or last commit, highlighting line-by-line differences.
* **Syntax:**
  ```bash
  git diff             # Diffs working directory against staging area
  git diff --staged    # Diffs staging area against the last commit (HEAD)
  ```
* **Example Usage:**
  ```bash
  # Check unstaged additions in a file
  git diff git-commands.md
  ```
* **Console Output:**
  ```diff
  diff --git a/git-commands.md b/git-commands.md
  index 45dfc12..3172e2b 100644
  --- a/git-commands.md
  +++ b/git-commands.md
  @@ -10,3 +10,10 @@
   | `git config` | Configures user identity settings globally | `git config --global user.name` |
   | `git init` | Initializes a new local Git repository | `git init` |
  +
  +## 🔍 Viewing Changes
  +
  +Use these commands to examine commit logs...
  +
  +| Command | Description | Example Usage |
  +| :--- | :--- | :--- |
  ```

### D. `git show`
* **What it does:** Displays the commit metadata (author, date, message) and the complete text diff introduced in a specific commit.
* **Syntax:**
  ```bash
  git show <commit-hash>
  ```
* **Example Usage:**
  ```bash
  git show dcd989b
  ```
* **Console Output:**
  ```diff
  commit dcd989b6574f8818c3b772c5b3648fa7d34190c1 (HEAD -> main)
  Author: rajatmehta2 <rajat.mehta2@gmail.com>
  Date:   Tue Jun 2 14:56:59 2026 +0530

      feat: add viewing changes section (log, diff, show)

  diff --git a/git-commands.md b/git-commands.md
  index ccf14b3..c21fa5e 100644
  --- a/git-commands.md
  +++ b/git-commands.md
  @@ -15,3 +15,11 @@
   | `git commit` | Saves staged changes to the project history | `git commit -m "Add new commands"` |
  +
  +## 🔍 Viewing Changes
  +
  +Use these commands to examine commit logs, track changes, and view file contents at specific revisions.
  +
  +| Command | Description | Example Usage |
  +| :--- | :--- | :--- |
  +| `git log` | Displays a detailed commit history log | `git log` |
  +| `git log --oneline` | Displays commit history in a compact, single-line format | `git log --oneline` |
  ```

---

## 🛡️ Git Best Practices for DevOps

To maintain high-quality codebases and seamless CI/CD automation, adhere to these Git best practices:

1. **Write Clean, Atomic Commits:** Each commit should represent exactly *one* logical change (e.g., configuring database credentials, adding standard logging, creating user forms). Avoid giant commits that solve multiple unrelated problems.
2. **Follow a Commit Message Convention:** Adopt structural message standards (such as **Conventional Commits**) to make pipelines easier to automate:
   * `feat: ...` for new functional extensions or scripts.
   * `fix: ...` for hotfixes or patch releases.
   * `docs: ...` for updates to markdown documentation.
   * `chore: ...` for updating dependencies or build tasks.
3. **Always Check Your Status:** Cultivate the habit of running `git status` and `git diff` *before* executing a stage (`git add`) and commit sequence. This prevents staging accidental temporary files or system logs.
4. **Leverage `.gitignore` Early:** Always define a `.gitignore` file inside your repository root on day one to prevent committing OS-specific files (`.DS_Store`), private configurations (`.env`), or large dependencies (`node_modules/`, `.venv/`).

---

## 🎨 Visual Reference Dashboard

Below is a custom-engineered terminal trace visual displaying our actual Git development logs and the repository's commit progression:

![Git Commit History Terminal Screenshot](git_history_screenshot.png)

---

Day 22 Complete 📘

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*