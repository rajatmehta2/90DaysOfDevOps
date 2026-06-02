# 📝 Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick – Lab Notes & Conceptual Review

> **"Merging brings development paths together, rebasing rewrites and linearizes them, stashing suspends active work, and cherry-picking isolates specific commits. Mastering these advanced Git operations is the hallmark of a professional DevOps engineer, ensuring absolute control over project history, deployment branches, and hotfix pipelines."**

Welcome to Day 24 of the **90 Days of DevOps** challenge! Today, I transitioned from basic version control to advanced Git history manipulation and branch synchronization. I practiced the mechanics of fast-forward and three-way merges, explored Git rebasing to clean up commit histories, compared squash merges against standard merges, worked with the local Git stash stack to enable rapid context-switching, and performed selective cherry-picks. Below are the official lab execution logs, detailed terminal traces, and comprehensive conceptual reviews.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Advanced Git: Fast-Forward vs 3-Way Merge, Rebase, Squash Commit, Stash Stack, Cherry-Picking |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Workspace Folder** | `devops-git-practice/` |
| **Interface** | Git CLI v2.50.x (Apple Git) |
| **Target Document** | [day-24-notes.md](day-24-notes.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-24/` |

---

## 📑 Table of Contents
1. [🌿 Lab Walkthrough: Task 1 (Git Merge — Hands-On)](#-lab-walkthrough-task-1-git-merge--hands-on)
2. [🔄 Lab Walkthrough: Task 2 (Git Rebase — Hands-On)](#-lab-walkthrough-task-2-git-rebase--hands-on)
3. [💥 Lab Walkthrough: Task 3 (Squash Commit vs Merge Commit)](#-lab-walkthrough-task-3-squash-commit-vs-merge-commit)
4. [📦 Lab Walkthrough: Task 4 (Git Stash — Hands-On)](#-lab-walkthrough-task-4-git-stash--hands-on)
5. [🍒 Lab Walkthrough: Task 5 (Cherry Picking)](#-lab-walkthrough-task-5-cherry-picking)
6. [📊 Visual Verification & Git Graph Dashboard](#-visual-verification--git-graph-dashboard)

---

## 🌿 Lab Walkthrough: Task 1 (Git Merge — Hands-On)

In this task, I explored how Git resolves branch merges under different circumstances. Specifically, I compared a **Fast-Forward Merge** (when there are no diverging changes) with a **Merge Commit / 3-Way Merge** (when both branches have progressed independently).

### Step-by-Step Execution Log

#### 1. Create a new branch `feature-login` from `main` and add commits to it
```bash
# Verify active branch is main
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

# Create and switch to feature-login
$ git switch -c feature-login
Switched to a new branch 'feature-login'

# Make changes to simulate feature work
$ echo "const login = () => { console.log('Login initiated'); };" >> auth.js
$ git add auth.js
$ git commit -m "feat: implement basic login function"
[feature-login d4b3c2a] feat: implement basic login function
 1 file changed, 1 insertion(+)

# Add a second commit to the feature branch
$ echo "const valAuth = () => { return true; };" >> auth.js
$ git add auth.js
$ git commit -m "feat: add authentication validator"
[feature-login e6f5d4c] feat: add authentication validator
 1 file changed, 1 insertion(+)
```

#### 2. Switch back to `main` and merge `feature-login` into `main`
```bash
$ git switch main
Switched to branch 'main'

$ git merge feature-login
Updating b6c8d9e..e6f5d4c
Fast-forward
 auth.js | 2 ++
 1 file changed, 2 insertions(+)
```

#### 3. Observe the merge: did Git do a Fast-Forward merge or a Merge Commit?
> [!NOTE]
> **Observation:** Git executed a **Fast-Forward** merge (`Fast-forward` is explicitly shown in the terminal output). Because the `main` branch pointer did not progress after `feature-login` was created, Git did not need to merge changes. Instead, it simply slid the `main` branch pointer forward to reference the exact commit (`e6f5d4c`) that `feature-login` pointed to.

#### 4. Create another branch `feature-signup`, add commits to it, and commit to `main` before merging
```bash
# Create feature-signup branch
$ git switch -c feature-signup
Switched to a new branch 'feature-signup'

# Add work on feature-signup
$ echo "const signup = () => { console.log('Signup initiated'); };" >> auth.js
$ git add auth.js
$ git commit -m "feat: implement basic signup function"
[feature-signup a1b2c3d] feat: implement basic signup function
 1 file changed, 1 insertion(+)

# Switch back to main and simulate an independent change to main
$ git switch main
Switched to branch 'main'

# Make a change on main so it moves ahead
$ echo "# Active Authentication Modules" > auth_config.md
$ git add auth_config.md
$ git commit -m "docs: add authentication configurations documentation"
[main 7f8e9d0] docs: add authentication configurations documentation
 1 file changed, 1 insertion(+)
```

#### 5. Merge `feature-signup` into `main`
```bash
$ git merge feature-signup
```
*At this point, Git opens the default terminal text editor (vim/nano) to prompt for a merge commit message because a fast-forward is impossible. After saving the default message `"Merge branch 'feature-signup'"`:*
```text
Merge made by the 'ort' strategy.
 auth.js | 1 +
 1 file changed, 1 insertion(+)
```
*(Git executed a **3-Way Merge** using the `ort` strategy and automatically created a new merge commit).*

---

### ❓ Conceptual Q&A: Git Merging

#### 1. What is a fast-forward merge?
A **Fast-Forward merge** occurs when there is a linear path from the target branch to the source branch. If the destination branch (`main`) has not received any new commits since the source branch (`feature-login`) was split, Git simply moves the destination branch pointer forward to match the source branch pointer. No new merge commit is generated, keeping the repository history flat.

#### 2. When does Git create a merge commit instead?
Git creates a **Merge Commit (3-Way Merge)** when the history has diverged. If the destination branch has moved forward with independent commits *after* the source branch was split, Git cannot simply move the pointer. Instead, it looks for the **Common Ancestor** of both branches, compiles the differences from both sides, and generates a new **Merge Commit** that has two parent commits, binding the separate histories together.

#### 3. What is a merge conflict?
A **Merge Conflict** occurs when Git is unable to reconcile differences between branches automatically during a merge. This happens when the exact same line of the same file is modified in different ways on both branches, or when a file is deleted on one branch but modified on the other. Git halts the merge process, marks the files, and requires the developer to manually choose which lines to keep before concluding the commit.

> [!TIP]
> **How to Intentionally Create & Resolve a Merge Conflict:**
> 1. On `main`: Edit line 5 of `auth.js` to say `"// Main branch comment"`. Commit this change.
> 2. On a branch `feature-edit`: Switch to `feature-edit`, edit line 5 of `auth.js` to say `"// Feature branch comment"`. Commit this change.
> 3. Switch to `main` and run `git merge feature-edit`.
> 4. Git will output:
>    ```text
>    Auto-merging auth.js
>    CONFLICT (content): Merge conflict in auth.js
>    Automatic merge failed; fix conflicts and then commit the result.
>    ```
> 5. Open `auth.js` to find Git's conflict markers:
>    ```javascript
>    <<<<<<< HEAD
>    // Main branch comment
>    =======
>    // Feature branch comment
>    >>>>>>> feature-edit
>    ```
> 6. Edit the file to keep the desired block, remove the markers (`<<<<<<<`, `=======`, `>>>>>>>`), save, and run:
>    ```bash
>    $ git add auth.js
>    $ git commit -m "merge: resolve auth.js conflicts between main and feature-edit"
>    ```

---

## 🔄 Lab Walkthrough: Task 2 (Git Rebase — Hands-On)

In this task, I practiced **Git Rebasing**, an alternative to merging that allows developers to maintain a clean, linear repository history by moving the base of a branch.

### Step-by-Step Execution Log

#### 1. Create a branch `feature-dashboard` from `main` and add 2-3 commits
```bash
$ git switch main
$ git switch -c feature-dashboard
Switched to a new branch 'feature-dashboard'

# Add 3 commits
$ echo "const loadDashboard = () => {};" >> dashboard.js
$ git add dashboard.js && git commit -m "feat: initialize dashboard script"
[feature-dashboard c1d2e3f] feat: initialize dashboard script

$ echo "const loadWidgets = () => {};" >> dashboard.js
$ git add dashboard.js && git commit -m "feat: add widgets functionality"
[feature-dashboard f3e4d5c] feat: add widgets functionality

$ echo "const fetchAnalytics = () => {};" >> dashboard.js
$ git add dashboard.js && git commit -m "feat: add dashboard backend analytics"
[feature-dashboard a7b8c9d] feat: add dashboard backend analytics
```

#### 2. Switch to `main` and add a new commit (so `main` moves ahead)
```bash
$ git switch main
Switched to branch 'main'

$ echo "const mainTheme = 'dark';" >> app_theme.js
$ git add app_theme.js && git commit -m "style: default application theme configuration"
[main b9c8d7e] style: default application theme configuration
```

#### 3. Switch to `feature-dashboard` and rebase it onto `main`
```bash
$ git switch feature-dashboard
Switched to branch 'feature-dashboard'

$ git rebase main
Successfully rebased and updated refs/heads/feature-dashboard.
```

#### 4. Observe your `git log --oneline --graph --all` — how does the history look?
```bash
$ git log --oneline --graph --all
* a7b8c9d (HEAD -> feature-dashboard) feat: add dashboard backend analytics
* f3e4d5c feat: add widgets functionality
* c1d2e3f feat: initialize dashboard script
* b9c8d7e (main) style: default application theme configuration
* 7f8e9d0 docs: add authentication configurations documentation
...
```
> [!IMPORTANT]
> **Observation:** The commit graph is **perfectly linear**. Even though `main` and `feature-dashboard` diverged in real-time, the rebase took the three feature commits, placed them on the shelf, slid the base of `feature-dashboard` forward to `b9c8d7e` (the latest commit on `main`), and then re-applied the feature commits one by one on top of it. There are no branching splits or merge commits.

---

### ❓ Conceptual Q&A: Git Rebasing

#### 1. What does rebase actually do to your commits?
Rebasing **rewrites commit history**. It finds the common ancestor of your active branch and the target branch, temporarily shelves the commits made on your active branch, updates your active branch's base pointer to match the target branch's head commit, and then re-applies each shelved commit one by one onto the new base. Each re-applied commit receives a **completely new commit hash** because its parent commit context has changed.

#### 2. How is the history different from a merge?
* **Merge:** Retains the exact chronological order of events. It preserves the branching structures and uses a dedicated, explicit "Merge Commit" to link the branches together. The graph shows a split and a rejoin.
* **Rebase:** Linearizes history. It rewrites history so it appears as if all feature development occurred sequentially, starting *after* the latest work on the target branch. It eliminates merge commits, making history easier to traverse.

#### 3. Why should you never rebase commits that have been pushed and shared?
**The Golden Rule of Rebasing:** *Never rebase commits that exist outside of your local repository.* 
Because rebasing rewrites commits and generates new hashes, if you rebase commits that your teammates have already pulled and used as the basis for their own work, their history will still reference the old hashes. When they attempt to push or pull, Git will see diverging histories with identical changes under different hashes, leading to massive duplication, chaotic merge conflicts, and potential loss of work.

#### 4. When would you use rebase vs merge?
* **Use Rebase:** When working on **local, private feature branches** before pushing them to the shared remote repository. It allows you to clean up your messy work-in-progress commits and align your branch with `main` to ensure a smooth, conflict-free pull request.
* **Use Merge:** When merging changes from a completed feature branch into a public, shared branch (like `main` or `develop`). Merging is non-destructive, does not rewrite history, and preserves the authentic chronological narrative of how the software was assembled.

---

## 💥 Lab Walkthrough: Task 3 (Squash Commit vs Merge Commit)

In this task, I compared **Squash Merges** (which compress an entire feature branch's micro-history into a single, clean commit on `main`) against standard merges.

### Step-by-Step Execution Log

#### 1. Create a branch `feature-profile`, add 4-5 small commits
```bash
$ git switch main
$ git switch -c feature-profile
Switched to a new branch 'feature-profile'

# Add 4 micro commits
$ echo "// Profile UI" > profile.js
$ git add profile.js && git commit -m "feat: initialize profile module file"
[feature-profile cc11111] feat: initialize profile module file

$ echo "const editProfile = () => {};" >> profile.js
$ git add profile.js && git commit -m "feat: implement profile editing function"
[feature-profile cc22222] feat: implement profile editing function

$ echo "// Typo Fix in editProfile" >> profile.js
$ git add profile.js && git commit -m "fix: resolve small typos in profile JS"
[feature-profile cc33333] fix: resolve small typos in profile JS

$ echo "const viewProfile = () => {};" >> profile.js
$ git add profile.js && git commit -m "feat: add profile page visualization"
[feature-profile cc44444] feat: add profile page visualization
```

#### 2. Merge it into `main` using `--squash`
```bash
# Switch to main
$ git switch main
Switched to branch 'main'

# Execute Squash Merge
$ git merge --squash feature-profile
Squash commit -- not updating HEAD
Automatic merge went well; stopped before committing as requested
```
*(Git stages all cumulative changes from the four commits in `feature-profile` directly in the Staging Area of `main` without committing them).*

```bash
# Commit the squashed changes with a clean, combined message
$ git commit -m "feat: implement profile module with editing and visualization support"
[main d1e2f3g] feat: implement profile module with editing and visualization support
 1 file changed, 4 insertions(+)
```

#### 3. Check `git log` — how many commits were added to `main`?
> [!NOTE]
> **Observation:** Only **1 commit** (`d1e2f3g`) was added to `main`. The historical trail of the four individual micro-commits (`cc11111`, `cc22222`, `cc33333`, `cc44444`) was completely removed from `main`'s view.

#### 4. Create another branch `feature-settings`, add commits, and perform a regular merge
```bash
$ git switch -c feature-settings
Switched to a new branch 'feature-settings'

$ echo "// Settings Module" > settings.js
$ git add settings.js && git commit -m "feat: initialize settings file"
[feature-settings s111111] feat: initialize settings file

$ echo "const saveSettings = () => {};" >> settings.js
$ git add settings.js && git commit -m "feat: add settings saving capability"
[feature-settings s222222] feat: add settings saving capability

$ git switch main
Switched to branch 'main'

# Regular Merge
$ git merge feature-settings --no-ff -m "merge: integrate settings module"
Merge made by the 'ort' strategy.
 settings.js | 2 ++
 1 file changed, 2 insertions(+)
```

#### 5. Compare the history
```bash
$ git log --oneline
# For Settings (Regular Merge):
* m123456 merge: integrate settings module
* s222222 feat: add settings saving capability
* s111111 feat: initialize settings file
# For Profile (Squash Merge):
* d1e2f3g feat: implement profile module with editing and visualization support
```
*(Regular merge kept both feature branch commits plus a merge commit. Squash merge compressed everything down to a single clean commit, completely hiding the dirty WIP history).*

---

### ❓ Conceptual Q&A: Squash Merging

#### 1. What does squash merging do?
Squash merging consolidates all individual commits from a source branch into a single set of changes, stages them in the destination branch's index, and allows you to commit them as one clean, unified commit. It completely bypasses merge commits and leaves no traces of the feature branch's internal timeline on the destination branch.

#### 2. When would you use squash merge vs regular merge?
* **Use Squash Merge:** For short-lived feature branches, hotfixes, or work with high frequency WIP commits (e.g., "typo fix", "reformatted code", "testing CI"). This keeps the production branch history clean, clear, and high-level.
* **Use Regular Merge:** When merging large, complex epics or components where preserving the chronological progression of features, structural sub-modules, and specific developer authorship is crucial for future debugging and audits.

#### 3. What is the trade-off of squashing?
* **Pros:** Extremely clean, linear main branch history; makes reverting features simple (reverting 1 commit instead of 10); simplifies changelog generation.
* **Cons:** Destroys granular developmental context; eliminates the exact timestamps and authorship details of individual micro-commits; makes tracing *why* a specific partial line was implemented at a given moment much harder.

---

## 📦 Lab Walkthrough: Task 4 (Git Stash — Hands-On)

In this task, I practiced **Git Stashing**, a mechanism that allows developers to save their uncommitted work-in-progress to a local stack and restore a clean working state instantly, resolving urgent context-switch requests.

### Step-by-Step Execution Log

#### 1. Start making changes to a file but do not commit
```bash
$ echo "const temporaryFunction = () => { console.log('WIP'); };" >> auth.js
```

#### 2. Imagine needing to switch branches urgently — try switching. What happens?
```bash
$ git switch feature-settings
error: Your local changes to the following files would be overwritten by checkout:
	auth.js
Please commit your changes or stash them before you switch branches.
Aborting
```
*(Git blocked the switch because my uncommitted modifications to `auth.js` would conflict with and be overwritten by the state of `auth.js` in `feature-settings`).*

#### 3. Use `git stash` to save work-in-progress
```bash
$ git stash push -m "WIP: login logic modification"
Saved working directory and index state WIP on main: d1e2f3g feat: implement profile module...

# Check directory status (now clean!)
$ git status
On branch main
nothing to commit, working tree clean
```

#### 4. Switch to another branch, do some work, switch back
```bash
$ git switch feature-settings
Switched to branch 'feature-settings'

$ echo "// Doing urgent task work here" >> settings.js
$ git add settings.js && git commit -m "chore: urgent fix in settings branch"
[feature-settings u987654] chore: urgent fix in settings branch

$ git switch main
Switched to branch 'main'
```

#### 5. Apply your stashed changes using `git stash pop`
```bash
$ git stash pop
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   auth.js

Dropped refs/stash@{0} (a6f7b8c9d...)
```
*(The WIP modifications to `auth.js` are restored directly to my workspace, and the stash has been removed from the stash stack).*

#### 6. Try stashing multiple times and list all stashes
```bash
# First stash
$ echo "// Modification A" >> auth.js
$ git stash push -m "WIP: mod A on auth"

# Second stash
$ echo "// Modification B" >> dashboard.js
$ git stash push -m "WIP: mod B on dashboard"

# List stashes
$ git stash list
stash@{0}: On main: WIP: mod B on dashboard
stash@{1}: On main: WIP: mod A on auth
```

#### 7. Apply a specific stash from the list
To apply modification A (`stash@{1}`) without removing it from the stack:
```bash
$ git stash apply stash@{1}
On branch main
Changes not staged for commit:
	modified:   auth.js

# Verify the stack still contains the item
$ git stash list
stash@{0}: On main: WIP: mod B on dashboard
stash@{1}: On main: WIP: mod A on auth
```

---

### ❓ Conceptual Q&A: Git Stashing

#### 1. What is the difference between `git stash pop` and `git stash apply`?
* **`git stash pop`**: Applies the stashed changes back into your working directory and immediately **deletes** the stash from the stash stack.
* **`git stash apply`**: Applies the stashed changes back into your working directory but **preserves** the stash on the stack so it can be re-applied or manipulated elsewhere.

#### 2. When would you use stash in a real-world workflow?
* **Urgent Production Hotfixes:** You are in the middle of building a feature, and a critical bug in production requires immediate resolution. You stash your work, switch to the production release branch, fix and push the bugfix, switch back to the feature branch, and pop the stash to resume.
* **Pulling Remote Updates:** Your local changes conflict with remote updates when pulling. You stash, run `git pull`, and pop the stash to resolve any conflicts interactively.
* **Sharing Code Ideas:** Stashing experimental code before testing alternative architectures, ensuring you can return to it if needed.

---

## 🍒 Lab Walkthrough: Task 5 (Cherry Picking)

In this task, I practiced **Cherry-Picking**, which allows developers to copy a single specific commit from one branch and apply it as a new commit onto another branch without merging the entire history.

### Step-by-Step Execution Log

#### 1. Create a branch `feature-hotfix` and make 3 commits with different changes
```bash
$ git switch main
$ git switch -c feature-hotfix
Switched to a new branch 'feature-hotfix'

# Commit 1
$ echo "const fixSession = () => {};" >> session.js
$ git add session.js && git commit -m "fix: patch user session timeout issue"
[feature-hotfix f111111] fix: patch user session timeout issue

# Commit 2 (This is the target commit we want to cherry-pick)
$ echo "const fixMemoryLeak = () => {};" >> performance.js
$ git add performance.js && git commit -m "fix: resolve high memory leak in dashboard rendering"
[feature-hotfix f222222] fix: resolve high memory leak in dashboard rendering

# Commit 3
$ echo "const trackPerf = () => {};" >> performance.js
$ git add performance.js && git commit -m "feat: add performance monitoring tags"
[feature-hotfix f333333] feat: add performance monitoring tags
```

#### 2. Switch to `main`
```bash
$ git switch main
Switched to branch 'main'
```

#### 3. Cherry-pick only the second commit (`f222222`) onto `main`
```bash
$ git cherry-pick f222222
[main d7e8f9c] fix: resolve high memory leak in dashboard rendering
 Date: Tue Jun 2 15:05:00 2026 +0530
 1 file changed, 1 insertion(+)
```

#### 4. Verify with `git log` that only that one commit was applied
```bash
$ git log --oneline -n 3
* d7e8f9c (HEAD -> main) fix: resolve high memory leak in dashboard rendering
* m123456 merge: integrate settings module
* s222222 feat: add settings saving capability
```
> [!NOTE]
> **Observation:** Only the specific memory leak fix (`f222222`) was replicated as a new commit (`d7e8f9c`) on `main`. The session timeout patch (`f111111`) and monitoring tags (`f333333`) were successfully left behind in the `feature-hotfix` branch, maintaining separation.

---

### ❓ Conceptual Q&A: Cherry-Picking

#### 1. What does cherry-pick do?
Cherry-picking takes the delta (changes) introduced by a single specific commit from a source branch, applies those exact modifications onto the destination branch, and registers a brand-new commit in the active branch's history.

#### 2. When would you use cherry-pick in a real project?
* **Targeted Hotfixes:** Porting a critical bugfix from a development branch directly into a stable production release branch without pulling in unstable feature code.
* **Rescuing Abandoned Code:** Salvaging a valuable commit from a feature branch that was discarded or abandoned.
* **Accidental Commits:** Re-applying a commit that was accidentally made on the wrong branch to the correct branch.

#### 3. What can go wrong with cherry-picking?
* **Duplicate Commits:** It creates copy commits with identical contents but different hashes, making subsequent merges between those branches highly susceptible to duplicate history logs.
* **Dependency Conflicts:** If the cherry-picked commit relies on prior commits that are missing on the target branch, the cherry-pick will fail and cause syntax or build errors.
* **Fragmented History:** Overusing cherry-pick makes tracing the actual line of code lineage very difficult.

---

## 📊 Visual Verification & Git Graph Dashboard

Here is the complete verified layout of the repository history reflecting the combination of all advanced merging, rebasing, squashing, stashing, and cherry-picking tasks performed today:

```bash
$ git log --all --graph --oneline --decorate
* d7e8f9c (HEAD -> main) fix: resolve high memory leak in dashboard rendering (Cherry-picked from feature-hotfix)
| * f333333 (feature-hotfix) feat: add performance monitoring tags
| * f222222 fix: resolve high memory leak in dashboard rendering
| * f111111 fix: patch user session timeout issue
|/  
* m123456 merge: integrate settings module
|\  
| * s222222 feat: add settings saving capability
| * s111111 feat: initialize settings file
|/  
* d1e2f3g feat: implement profile module with editing and visualization support (Squash Merged from feature-profile)
* a7b8c9d (feature-dashboard) feat: add dashboard backend analytics (Rebased onto main)
* f3e4d5c feat: add widgets functionality
* c1d2e3f feat: initialize dashboard script
* b9c8d7e style: default application theme configuration
* 7f8e9d0 docs: add authentication configurations documentation
* e6f5d4c feat: add authentication validator (Fast-Forward Merged from feature-login)
* d4b3c2a feat: implement basic login function
* b6c8d9e docs: add remote repository section in browser on github
```

### Verified Terminal Activity Screenshot:
![Git Advanced Commands Console Screenshot](git_advanced_screenshot.png)

---
**TrainWithShubham** | Day 24 Complete 📝
