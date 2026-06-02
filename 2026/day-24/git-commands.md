# 📘 Day 24 – Git Advanced Operations: Merge, Rebase, Squash, Stash & Cherry-Pick Commands Reference Guide

> **"Advanced Git commands are the levers of architectural control in source configuration management. Mastery of fast-forward controls, rebasing pipelines, squash merging strategies, stashing stacks, and cherry-picking protocols represents the divide between passive version tracking and professional DevOps release engineering."**

Welcome to Day 24 of the **90 Days of DevOps** challenge! This is a comprehensive, production-grade **Git Advanced Operations Commands Reference Guide**. Designed as a high-density, zero-friction developer cheat sheet, it covers merging controls, histories linearization via rebasing, history-compressing squash merges, localized stash-stack cache workflows, and selective commit cherry-picks.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Git Advanced History & Branching: Merges, Rebases, Squashing, Stash-Stack Cache, Cherry-Picking |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Interface** | Git CLI v2.50.x (Apple Git) |
| **Target Document** | [git-commands.md](git-commands.md) |
| **Key Command Interfaces** | `git merge`, `git rebase`, `git stash`, `git cherry-pick`, `git log` |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-24/` |

---

## 📑 Table of Contents
1. [📊 Quick Reference Commands Matrix](#-quick-reference-commands-matrix)
2. [🌿 1. Git Merging Operations](#-1-git-merging-operations)
3. [🔄 2. Git Rebasing Operations](#-2-git-rebasing-operations)
4. [💥 3. Squash Merging Operations](#-3-squash-merging-operations)
5. [📦 4. Git Stashing (Work-In-Progress Cache)](#-4-git-stashing-work-in-progress-cache)
6. [🍒 5. Git Cherry-Picking Operations](#-5-git-cherry-picking-operations)
7. [🛡️ DevOps Advanced Git History Best Practices](#-devops-advanced-git-history-best-practices)
8. [🎨 Visual History & Commit flow Dashboard](#-visual-history--commit-flow-dashboard)

---

## 📊 Quick Reference Commands Matrix

Below is a syntax lookup matrix summarizing advanced Git history and stash operations for daily DevOps engineering:

| Category | Command Syntax | Description (1 Line Summary) | DevOps Use Case |
| :--- | :--- | :--- | :--- |
| **Merge** | `git merge <branch>` | Integrates the specified branch into the active branch (Fast-forward if possible). | Pulling local features into release branches. |
| **Merge** | `git merge --no-ff <branch>` | Forces Git to generate a Merge Commit even if a fast-forward is possible. | Retaining visual records of feature integrations. |
| **Merge** | `git merge --squash <branch>` | Combines all source commits into one uncommitted change staged on destination. | Condensing a messy local feature into a single clean commit. |
| **Rebase** | `git rebase <base-branch>` | Shelves active branch commits and re-applies them onto the target branch head. | Linearizing feature branch changes before raising pull requests. |
| **Rebase** | `git rebase --continue` | Resumes a paused rebase operation after manually resolving conflicts. | Resolving incremental conflicts during interactive rebases. |
| **Rebase** | `git rebase --abort` | Cancels the active rebase operation and restores the branch to pre-rebase state. | Safely recovering from complex or broken rebase merges. |
| **Rebase** | `git rebase -i <commit>` | Launches interactive menu to squash, edit, reorder, or drop local commits. | Cleaning up commit logs before pushing to shared branches. |
| **Stash** | `git stash push -m "msg"` | Saves uncommitted modifications to the stash stack and cleans working directory. | Pausing current tasks to handle critical production hotfixes. |
| **Stash** | `git stash list` | Lists all cached stashes stored on the local repository stack. | Auditing saved WIP chunks before applying them. |
| **Stash** | `git stash pop` | Applies the latest stashed change to working tree and deletes it from stash. | Restoring paused work to resume active coding. |
| **Stash** | `git stash apply <stash_ref>`| Applies a specific stashed change to working tree but keeps it on the stack. | Replicating a stash chunk on multiple branches or testing ideas. |
| **Stash** | `git stash drop <stash_ref>`| Deletes a specific stashed change from the local repository stack. | Cleaning up stale stashes that are no longer needed. |
| **Stash** | `git stash clear` | Deletes all stashed changes from the local repository stash. | Clearing the local stash cache space. |
| **Cherry-Pick**| `git cherry-pick <commit>` | Copies a single specific commit from another branch onto the active branch. | Applying a targeted hotfix from dev to a production branch. |

---

## 🌿 1. Git Merging Operations

Merging brings separate branch histories together by integrating the changes from one branch into another.

### A. `git merge` (Standard Merge)
* **What it does:** Merges the specified branch into the current branch. Performs a fast-forward merge if there are no diverging commits, or a 3-way merge commit if history has split.
* **Syntax:**
  ```bash
  git merge <branch-name>
  ```
* **Example Usage:**
  ```bash
  git merge feature-login
  ```
* **Console Output (Fast-Forward):**
  ```text
  Updating b6c8d9e..e6f5d4c
  Fast-forward
   auth.js | 2 ++
   1 file changed, 2 insertions(+)
  ```

---

### B. `git merge --no-ff` (No Fast-Forward Merge)
* **What it does:** Forces Git to create a merge commit even if the merge could be performed as a fast-forward. This preserves the historical context that a branch existed and was integrated at this point.
* **Syntax:**
  ```bash
  git merge --no-ff <branch-name> -m "commit message"
  ```
* **Example Usage:**
  ```bash
  git merge --no-ff feature-login -m "merge: integrate login feature"
  ```
* **Console Output:**
  ```text
  Merge made by the 'ort' strategy.
   auth.js | 2 ++
   1 file changed, 2 insertions(+)
  ```

---

## 🔄 2. Git Rebasing Operations

Rebasing rewrites commit histories by moving the base of the active branch to a new starting commit, creating a clean linear path.

### A. `git rebase` (Rebase branch onto base)
* **What it does:** Updates the branch's starting point to match the latest commit of the specified target branch, re-applying local commits chronologically.
* **Syntax:**
  ```bash
  git rebase <base-branch-name>
  ```
* **Example Usage:**
  ```bash
  git rebase main
  ```
* **Console Output:**
  ```text
  Successfully rebased and updated refs/heads/feature-dashboard.
  ```

---

### B. Rebase Control Commands (`--continue` / `--abort`)
* **What it does:** Manages rebasing states when paused due to merge conflicts. `--continue` resumes rebase after adding resolved changes. `--abort` terminates rebase and restores original workspace.
* **Syntax:**
  ```bash
  git rebase --continue
  git rebase --abort
  ```
* **Example Usage (Resolving Conflict):**
  ```bash
  # Resolve conflicts in editor...
  git add auth.js
  git rebase --continue
  ```

---

### C. `git rebase -i` (Interactive Rebase)
* **What it does:** Opens an interactive editor containing a list of commits, allowing you to reorder, edit, delete, or combine (squash) them before sharing.
* **Syntax:**
  ```bash
  git rebase -i <commit-hash-or-ref>
  ```
* **Example Usage (Rebase last 3 commits):**
  ```bash
  git rebase -i HEAD~3
  ```
* **Interactive Editor Menu Simulation:**
  ```text
  pick d4b3c2a feat: implement basic login function
  squash e6f5d4c feat: add authentication validator
  pick a1b2c3d feat: implement basic signup function

  # Rebase b6c8d9e..a1b2c3d onto b6c8d9e (3 commands)
  ```

---

## 💥 3. Squash Merging Operations

Squash merging simplifies history by compressing an entire feature branch's timeline into a single, comprehensive commit on the target branch.

### A. `git merge --squash`
* **What it does:** Extracts all differences from a source branch, applies them as a single staged change on the destination branch, and stops. You must then manually commit the squashed change.
* **Syntax:**
  ```bash
  git merge --squash <source-branch>
  git commit -m "unified clean message"
  ```
* **Example Usage:**
  ```bash
  git merge --squash feature-profile
  git commit -m "feat: implement profile module with editing and visualization support"
  ```
* **Console Output:**
  ```text
  Squash commit -- not updating HEAD
  Automatic merge went well; stopped before committing as requested
  [main d1e2f3g] feat: implement profile module with editing and visualization support
   1 file changed, 4 insertions(+)
  ```

---

## 📦 4. Git Stashing (Work-In-Progress Cache)

Stashing clears the workspace by storing dirty local changes in a stack-based cache, facilitating fast context-switching.

### A. `git stash push` (Save to Stack)
* **What it does:** Saves both tracked and staged local changes to the stash stack and leaves a clean workspace. The `-m` flag assigns a human-readable message to the stash.
* **Syntax:**
  ```bash
  git stash push -m "description of work"
  ```
* **Example Usage:**
  ```bash
  git stash push -m "WIP: auth.js login validation layout"
  ```
* **Console Output:**
  ```text
  Saved working directory and index state WIP on main: d1e2f3g feat: implement profile module...
  ```

---

### B. `git stash list` & `git stash show`
* **What it does:** `stash list` shows all saved stashes on the stack. `stash show` reveals the diff details of a specific stash entry.
* **Syntax:**
  ```bash
  git stash list
  git stash show -p <stash_ref>
  ```
* **Example Usage:**
  ```bash
  git stash list
  git stash show -p stash@{0}
  ```
* **Console Output:**
  ```text
  stash@{0}: On main: WIP: mod B on dashboard
  stash@{1}: On main: WIP: mod A on auth
  ```

---

### C. `git stash pop` vs `git stash apply`
* **What it does:** Restores stashed changes. `pop` restores the changes and deletes the stash from the stack. `apply` restores the changes but keeps the stash on the stack.
* **Syntax:**
  ```bash
  git stash pop
  git stash apply <stash_ref>
  ```
* **Example Usage:**
  ```bash
  git stash pop
  git stash apply stash@{1}
  ```
* **Console Output (Pop):**
  ```text
  On branch main
  Changes not staged for commit:
  	modified:   auth.js

  Dropped refs/stash@{0} (a6f7b8c9d...)
  ```

---

### D. `git stash drop` vs `git stash clear`
* **What it does:** `drop` deletes a specific stash from the stack. `clear` deletes all stashes.
* **Syntax:**
  ```bash
  git stash drop <stash_ref>
  git stash clear
  ```
* **Example Usage:**
  ```bash
  git stash drop stash@{0}
  ```
* **Console Output:**
  ```text
  Dropped stash@{0} (b7e8d9c6a...)
  ```

---

## 🍒 5. Git Cherry-Picking Operations

Cherry-picking duplicates a single specific commit from a source branch and registers it as a new commit on the active branch.

### A. `git cherry-pick`
* **What it does:** Extracts the changes from a specified commit hash and applies them as a new commit on the current branch.
* **Syntax:**
  ```bash
  git cherry-pick <commit-hash>
  ```
* **Example Usage:**
  ```bash
  git cherry-pick f222222
  ```
* **Console Output:**
  ```text
  [main d7e8f9c] fix: resolve high memory leak in dashboard rendering
   Date: Tue Jun 2 15:05:00 2026 +0530
   1 file changed, 1 insertion(+)
  ```

---

## 🛡️ DevOps Advanced Git History Best Practices

To maintain production stability and readable code history in enterprise release pipelines:

1. **Observe the Rebasing Golden Rule:** *Never rebase commits that have been pushed and shared with a public repository.* Rebasing shared history forces duplicate commits and breaks teammates' working copies.
2. **Squash Feature Branches Before Merging:** Keep your main development branches clean by squashing feature branches with high-frequency micro-commits (`typo fix`, `formatting`, `working`) into a single, well-documented commit when creating Pull Requests.
3. **Use Stash with Messages:** Always use `git stash push -m "detailed message"` rather than the generic `git stash`. Having multiple stashes called "WIP on branch" makes it incredibly difficult to find the correct stash later.
4. **Use Cherry-Pick for Hotfixes Only:** Do not use cherry-picking as a standard method to move features between branches. Reserve it for urgent bug hotfixes or rescuing commits from dead/abandoned branches.
5. **Always Verify History Visually:** Establish a pipeline habit of running `git log --oneline --graph --all` to audit your branches, merges, and commit lines before running deployment pipelines or pushing major releases.

---

## 🎨 Visual History & Commit flow Dashboard

Below is the visual structure of how commits flow, branch, and merge using the advanced command architectures:

![Git Advanced Commands Console Screenshot](git_advanced_screenshot.png)

---
**TrainWithShubham** | Day 24 Complete 📘
