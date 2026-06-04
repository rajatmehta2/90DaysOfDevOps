# 📘 Day 23 – Git Branching & GitHub Commands Reference Guide

> **"Branching and remote collaboration are what elevate Git from a local utility to a global DevOps engineering pipeline. Mastering branch segregation, remote pushing/pulling, and fork synchronization commands is the baseline requirement for maintaining robust CI/CD codeflows and participating in open-source development."**

Welcome to Day 23 of the **90 Days of DevOps** challenge! This is a comprehensive, production-grade **Git Branching & GitHub Commands Reference Guide**. Designed as a high-density, zero-friction developer cheat sheet, it covers local branch management, modern branch switching, remote repository integrations, fetching/pulling flows, forking architectures, and fork synchronization workflows.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Local Branching, Switch vs Checkout, Remote Repository Connectors, GitHub Push/Pull, Fork/Clone Sync Pipelines |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Interface** | Git CLI v2.50.x (Apple Git) |
| **Target Document** | [git-commands.md](git-commands.md) |
| **Key Command Interfaces** | `git branch`, `git switch`, `git checkout`, `git remote`, `git push`, `git fetch`, `git pull`, `git clone` |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-23/` |

---

## 📑 Table of Contents
1. [📊 Quick Reference Commands Matrix](#-quick-reference-commands-matrix)
2. [🌿 1. Local Branch Management](#-1-local-branch-management)
3. [📡 2. Remote Repository & GitHub Connections](#-2-remote-repository--github-connections)
4. [🔄 3. Distributed Sync & Fork Maintenance](#-3-distributed-sync--fork-maintenance)
5. [🛡️ DevOps Git Branching & Syncing Best Practices](#-devops-git-branching--syncing-best-practices)
6. [🎨 Visual Branching & GitHub Flow Dashboard](#-visual-branching--github-flow-dashboard)

---

## 📊 Quick Reference Commands Matrix

Below is a syntax lookup matrix summarizing Git branching and GitHub remote synchronization operations for daily engineering:

| Category | Command Syntax | Description (1 Line Summary) | DevOps Use Case |
| :--- | :--- | :--- | :--- |
| **Branching** | `git branch` | Lists all local branches; highlights the active branch with an asterisk (`*`). | Auditing local branch context before starting work. |
| **Branching** | `git branch -a` | Lists all local and remote-tracking branches in the repository. | Investigating branches available on local and remote server. |
| **Branching** | `git branch <name>` | Creates a new branch pointer referencing the current commit snapshot. | Starting a new isolated feature or hotfix workspace. |
| **Branching** | `git switch <name>` | Switches the workspace context and HEAD pointer to the specified branch. | Moving between isolated features or hotfixes to resume work. |
| **Branching** | `git switch -c <name>` | Creates a new branch and immediately switches the workspace to it. | Instant bootstrapping of a feature workspace in one step. |
| **Branching** | `git branch -d <name>` | Safely deletes a branch if its changes have been successfully merged. | Cleaning up stale, post-merged feature branches. |
| **Branching** | `git branch -D <name>` | Forces the deletion of a branch, even if it contains unmerged changes. | Discarding failed experimental branches and features. |
| **Remotes** | `git remote add <name> <url>`| Connects a local repository to a remote repository URL under an alias. | Connecting a newly created local repo to GitHub or GitLab. |
| **Remotes** | `git remote -v` | Lists all configured remote aliases and their corresponding fetch/push URLs. | Auditing which remote server repositories are connected. |
| **Syncing** | `git push -u <remote> <branch>`| Pushes branch to remote and sets a persistent tracking upstream link. | Uploading local branches to GitHub for the first time. |
| **Syncing** | `git push <remote> <branch>` | Uploads local branch commits to the remote tracking branch. | Sharing ongoing development commits with teammates. |
| **Syncing** | `git fetch <remote>` | Safe read-only download of all commits and refs from the remote server. | Auditing remote changes before merging or reviewing code. |
| **Syncing** | `git pull <remote> <branch>` | Downloads remote commits and immediately merges them into active local branch. | Syncing local workspace with remote changes. |
| **Forking** | `git clone <url>` | Downloads a remote repository copy and sets up local working tree. | Establishing a local copy of a team or open source repository. |

---

## 🌿 1. Local Branch Management

These commands govern the creation, listing, switching, and deletion of isolated developer workspaces on your local machine.

### A. `git branch` (List and Create)
* **What it does:** Without arguments, it lists all local branches in the repository. With a name argument, it creates a new branch pointer at the current commit.
* **Syntax:**
  ```bash
  git branch                # List local branches
  git branch -a             # List local and remote branches
  git branch <branch-name>  # Create a new branch
  ```
* **Example Usage:**
  ```bash
  git branch feature-1
  ```
* **Console Output:**
  ```text
  # Command runs silently, creating .git/refs/heads/feature-1
  ```

---

### B. `git switch` vs `git checkout`
* **What it does:** Switches the working directory files and updates the `HEAD` pointer to the specified target branch. `git switch` is the modern, dedicated command introduced to replace the overloaded `git checkout`.
* **Syntax:**
  ```bash
  git switch <branch-name>             # Switch branches (Modern)
  git checkout <branch-name>           # Switch branches (Legacy)
  
  git switch -c <new-branch-name>      # Create and switch in one step (Modern)
  git checkout -b <new-branch-name>    # Create and switch in one step (Legacy)
  ```
* **Example Usage:**
  ```bash
  git switch -c feature-2
  ```
* **Console Output:**
  ```text
  Switched to a new branch 'feature-2'
  ```

---

### C. `git branch -d` / `git branch -D` (Delete)
* **What it does:** Deletes a local branch pointer. `-d` is a safe delete that prevents loss of unmerged code. `-D` is a force delete that bypasses safety checks.
* **Syntax:**
  ```bash
  git branch -d <branch-name>  # Safe delete (only deletes if merged)
  git branch -D <branch-name>  # Force delete (deletes regardless of merge status)
  ```
* **Example Usage:**
  ```bash
  git branch -d feature-2
  ```
* **Console Output:**
  ```text
  Deleted branch feature-2 (was fefbd32).
  ```

---

## 📡 2. Remote Repository & GitHub Connections

These commands bridge the gap between your isolated local machine and centralized remote hosting servers like GitHub.

### A. `git remote add` & `git remote -v`
* **What it does:** Configures a connection to a remote repository URL under a friendly alias (usually `origin`). `git remote -v` lists your configured remote connections.
* **Syntax:**
  ```bash
  git remote add <alias-name> <repository-url>
  git remote -v
  ```
* **Example Usage:**
  ```bash
  git remote add origin https://github.com/rajatmehta2/devops-git-practice.git
  git remote -v
  ```
* **Console Output:**
  ```text
  origin  https://github.com/rajatmehta2/devops-git-practice.git (fetch)
  origin  https://github.com/rajatmehta2/devops-git-practice.git (push)
  ```

---

### B. `git push` & Upstream Tracking
* **What it does:** Uploads local commit history and branch refs to the designated remote repository. The `-u` (or `--set-upstream`) flag links your local branch to the remote branch so future commands require just `git push` or `git pull`.
* **Syntax:**
  ```bash
  git push -u <remote-name> <branch-name>    # Push and link upstream tracking
  git push                                   # Push current branch (if upstream is linked)
  ```
* **Example Usage:**
  ```bash
  git push -u origin main
  ```
* **Console Output:**
  ```text
  Enumerating objects: 15, done.
  Counting objects: 100% (15/15), done.
  Writing objects: 100% (15/15), 11.23 KiB | 2.81 MiB/s, done.
  To https://github.com/rajatmehta2/devops-git-practice.git
   * [new branch]      main -> main
  branch 'main' set up to track 'origin/main'.
  ```

---

## 🔄 3. Distributed Sync & Fork Maintenance

These commands are used to download updates from shared repositories and keep independent forked repositories in sync with the primary project.

### A. `git fetch` vs `git pull`
* **What it does:** `git fetch` downloads all new history, commits, and branches from the remote repository but does **not** merge them into your local files. `git pull` downloads remote changes and immediately runs `git merge` to integrate them into your active local branch.
* **Syntax:**
  ```bash
  git fetch <remote-name>                    # Safe download only
  git pull <remote-name> <branch-name>       # Download and merge immediately
  ```
* **Example Usage:**
  ```bash
  git pull origin main
  ```
* **Console Output:**
  ```text
  remote: Enumerating objects: 5, done.
  Updating 77237ca..b6c8d9e
  Fast-forward
   git-commands.md | 12 ++++++++++++
   1 file changed, 12 insertions(+)
  ```

---

### B. Syncing a Forked Repository
* **What it does:** Keeps your local workspace and remote fork synchronized with the original, central repository (traditionally aliased as `upstream`).
* **Syntax Pipeline:**
  ```bash
  # 1. Connect to original repository as "upstream"
  git remote add upstream <original-repository-url>
  
  # 2. Fetch all changes from upstream
  git fetch upstream
  
  # 3. Switch to your main branch
  git switch main
  
  # 4. Merge upstream's main branch into your local main
  git merge upstream/main
  
  # 5. Push the updated local main branch to your remote GitHub fork
  git push origin main
  ```

---

## 🛡️ DevOps Git Branching & Syncing Best Practices

Adhering to professional branching strategies ensures stability in continuous integration and continuous deployment (CI/CD) environments:

1. **Keep the Main Branch Deployable:** Treat `main` (or `master`) as production-ready code. Never commit directly to it; always merge through peer-reviewed Pull Requests.
2. **Use Short-Lived Feature Branches:** Create specific, short-lived branches for single features or fixes (e.g., `feature/cognito-login` or `hotfix/redis-expiry`). Merge them quickly back into development pipelines to prevent large, painful merge conflicts.
3. **Establish a Naming Convention:** Enforce uniform naming conventions for team organization:
   * `feature/` for new application capabilities.
   * `bugfix/` or `hotfix/` for application issues.
   * `release/` for pre-production builds.
4. **Fetch and Review Before Merging:** Avoid automatic merges when working with shared branches. Cultivate the habit of running `git fetch origin` followed by `git log HEAD..origin/main` to review what changes are arriving from the team before merging.
5. **Always Clean Up Stale Branches:** Once a branch is merged into `main` and successfully deployed, delete both your local branch (`git branch -d`) and remote branch (`git push origin --delete`) to maintain a clean codebase directory.

---

## 🎨 Visual Branching & GitHub Flow Dashboard

Below is a visualization of how commits dived and merged during our local branching exercises, tracking the integration with GitHub remotes:

![Git Branching & GitHub Push Console Screenshot](git_branching_screenshot.png)

---

Day 23 Complete 📘

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*