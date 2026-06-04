# 📝 Day 25 – Git Reset vs Revert & Branching Strategies – Lab Notes & Conceptual Review

> **"Undoing a mistake in version control is not just about recovery; it is about preserving the historical integrity of your source configuration. Selecting the right mechanism—whether rewriting history locally via reset or recording a counter-history via revert—defines your reliability as a DevOps release engineer, while choosing the right branching strategy dictates how your team scales."**

Welcome to Day 25 of the **90 Days of DevOps** challenge! Today, I explored Git's safety nets and architectural management systems. I practiced the mechanics of safely undoing mistakes using `git reset` (soft, mixed, and hard variants) and `git revert`, compared their differences in multi-developer environments, and analyzed the core branching strategies—GitFlow, GitHub Flow, and Trunk-Based Development—used by enterprise teams to manage software lifecycles at scale. Below are the execution records, terminal logs, conceptual deep-dives, and strategy blueprints.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Git Reset (Soft, Mixed, Hard), Git Revert, Branching Strategies (GitFlow, GitHub Flow, Trunk-Based) |
| **Operating System** | macOS (Darwin Kernel 25.x) & POSIX Linux Reference |
| **Workspace Folder** | `devops-git-practice/` |
| **Interface** | Git CLI v2.50.x (Apple Git) |
| **Target Documents** | [day-25-notes.md](day-25-notes.md), [git-commands.md](git-commands.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-25/` |

---

## 📑 Table of Contents
1. [🌿 Lab Walkthrough: Task 1 (Git Reset — Hands-On)](#-lab-walkthrough-task-1-git-reset--hands-on)
2. [🔄 Lab Walkthrough: Task 2 (Git Revert — Hands-On)](#-lab-walkthrough-task-2-git-revert--hands-on)
3. [⚖️ Task 3: Git Reset vs Git Revert — Comprehensive Comparison](#-task-3-git-reset-vs-git-revert--comprehensive-comparison)
4. [🏗️ Task 4: Industry Branching Strategies Blueprint](#-task-4-industry-branching-strategies-blueprint)
5. [📊 Visual Verification & Git Graph Dashboard](#-visual-verification--git-graph-dashboard)

---

## 🌿 Lab Walkthrough: Task 1 (Git Reset — Hands-On)

In this hands-on lab, I analyzed how Git behaves when resetting commits using different flags (`--soft`, `--mixed`, `--hard`). This task demonstrates how each option impacts the **three trees of Git**: the *Commit History (HEAD)*, the *Staging Area (Index)*, and the *Working Directory*.

### Step-by-Step Execution Log

#### 1. Setup a Clean Branch and Create 3 Commits (Commit A, B, and C)
```bash
# Switch to a clean practice branch
$ git switch main
$ git switch -c lab-reset-practice
Switched to a new branch 'lab-reset-practice'

# Commit A: Initialize index page
$ echo "<h1>App v1.0.0</h1>" > index.html
$ git add index.html
$ git commit -m "feat: commit A - initialize index page structure"
[lab-reset-practice a1a1a1a] feat: commit A - initialize index page structure
 1 file changed, 1 insertion(+)

# Commit B: Add navbar module
$ echo "<nav><ul><li>Home</li><li>Dashboard</li></ul></nav>" >> index.html
$ git add index.html
$ git commit -m "feat: commit B - implement primary navigation bar"
[lab-reset-practice b2b2b2b] feat: commit B - implement primary navigation bar
 1 file changed, 1 insertion(+)

# Commit C: Add footer content
$ echo "<footer>Copyright 2026</footer>" >> index.html
$ git add index.html
$ git commit -m "feat: commit C - append copyright footer"
[lab-reset-practice c3c3c3c] feat: commit C - append copyright footer
 1 file changed, 1 insertion(+)

# Audit initial history
$ git log --oneline -n 3
c3c3c3c (HEAD -> lab-reset-practice) feat: commit C - append copyright footer
b2b2b2b feat: commit B - implement primary navigation bar
a1a1a1a feat: commit A - initialize index page structure
```

#### 2. Execute `git reset --soft`
I used `--soft` to undo the latest commit (Commit C) and check the status of my files.
```bash
# Reset soft back one commit (to Commit B)
$ git reset --soft HEAD~1

# Check Git history (Commit C is gone from active log)
$ git log --oneline -n 2
b2b2b2b (HEAD -> lab-reset-practice) feat: commit B - implement primary navigation bar
a1a1a1a feat: commit A - initialize index page structure

# Verify state of the Staging Area and Working Directory
$ git status
On branch lab-reset-practice
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   index.html
```
> [!NOTE]
> **Observation (`--soft`):** The pointer `HEAD` moved back to Commit B (`b2b2b2b`). However, the modifications introduced in Commit C (the footer code) remain **fully staged** in the Index. No modifications were lost in the working directory.

#### 3. Re-commit and Execute `git reset --mixed`
I committed the staged changes again to restore Commit C, then performed a `--mixed` (default) reset.
```bash
# Re-commit the changes to restore Commit C
$ git commit -m "feat: commit C - append copyright footer"
[lab-reset-practice c3c3c3c] feat: commit C - append copyright footer

# Reset mixed back one commit (default behavior)
$ git reset --mixed HEAD~1
Unstaged changes after reset:
M	index.html

# Verify Staging Area vs Working Directory
$ git status
On branch lab-reset-practice
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   index.html
```
> [!NOTE]
> **Observation (`--mixed`):** The pointer `HEAD` moved back to Commit B. The modifications from Commit C were **removed from the Staging Area** (unstaged), but they are **fully preserved** inside the Working Directory as local modifications.

#### 4. Re-commit and Execute `git reset --hard`
I staged and re-committed the changes to restore Commit C, then performed a `--hard` reset to go back to Commit B.
```bash
# Re-commit to restore Commit C
$ git add index.html
$ git commit -m "feat: commit C - append copyright footer"
[lab-reset-practice c3c3c3c] feat: commit C - append copyright footer

# Reset hard back one commit
$ git reset --hard HEAD~1
HEAD is now at b2b2b2b feat: commit B - implement primary navigation bar

# Verify Staging Area, Working Directory and File Contents
$ git status
On branch lab-reset-practice
nothing to commit, working tree clean

$ cat index.html
<h1>App v1.0.0</h1>
<nav><ul><li>Home</li><li>Dashboard</li></ul></nav>
```
> [!WARNING]
> **Observation (`--hard`):** This is a **destructive** operation. The pointer `HEAD` moved back to Commit B. The staging area was cleared, and the changes introduced by Commit C (the footer element in `index.html`) were **permanently deleted** from the working directory. 

---

### ❓ Conceptual Q&A: Git Reset

#### 1. What is the difference between `--soft`, `--mixed`, and `--hard`?
The difference lies in how each option affects Git's tree layers:
* **`--soft`**: Only updates the `HEAD` pointer to the target commit. The Staging Area (Index) and the Working Directory are left completely untouched. Your changes remain staged, ready for another commit.
* **`--mixed`** (default): Updates the `HEAD` pointer and synchronizes the Staging Area to match. The Working Directory remains untouched. Your changes are kept as local, unstaged modifications.
* **`--hard`**: Updates the `HEAD` pointer, the Staging Area, and the Working Directory to match the target commit. All uncommitted changes and all commits newer than the target commit are completely erased from your active workspace.

#### 2. Which one is destructive and why?
**`--hard` is destructive.** It does not just move history pointers; it overwrites the files in your physical Working Directory to match the target commit state. Any uncommitted local modifications or newly created files are immediately lost.
> [!TIP]
> **Safety Net:** If you accidentally perform a `git reset --hard` and lose commits, you can use **`git reflog`** to locate the commit hash of your deleted commit (e.g., Commit C `c3c3c3c`) and run `git reset --hard c3c3c3c` to restore it!

#### 3. When would you use each one?
* **`--soft`**: Use when you want to undo a commit to **re-word the commit message** or **combine (squash)** several small commits before sharing them.
* **`--mixed`**: Use when you committed something too early, or forgot to add a file, and want to **re-stage** your changes systematically.
* **`--hard`**: Use when your current developmental approach is a complete failure, and you want to **wipe your slate clean** to return directly to a known stable state.

#### 4. Should you ever use `git reset` on commits that are already pushed?
**No.** Resetting commits that have been pushed to a remote, shared repository rewrites the branch history. When other developers attempt to pull from that branch, their histories will conflict with yours, resulting in duplicate commits, broken merges, and major disruption for the team.

---

## 🔄 Lab Walkthrough: Task 2 (Git Revert — Hands-On)

In this task, I explored **`git revert`**, which provides a safe way to undo changes on public, shared branches by recording a new commit that applies the inverse of an older commit.

### Step-by-Step Execution Log

#### 1. Create 3 Commits (Commit X, Y, and Z)
```bash
# Switch to a clean branch
$ git switch main
$ git switch -c lab-revert-practice
Switched to a new branch 'lab-revert-practice'

# Commit X: Add core API controller
$ echo "const coreApi = () => { console.log('Core Loaded'); };" > server.js
$ git add server.js && git commit -m "feat: commit X - initialize core API controller"
[lab-revert-practice x1x1x1x] feat: commit X - initialize core API controller
 1 file changed, 1 insertion(+)

# Commit Y: Add analytics tracking (simulation of a bug-inducing commit)
$ echo "const tracking = () => { console.log('Tracking analytics'); };" >> server.js
$ git add server.js && git commit -m "feat: commit Y - append analytics tracking module"
[lab-revert-practice y2y2y2y] feat: commit Y - append analytics tracking module
 1 file changed, 1 insertion(+)

# Commit Z: Add healthcheck endpoint
$ echo "const health = () => { return 'OK'; };" >> server.js
$ git add server.js && git commit -m "feat: commit Z - implement system healthcheck"
[lab-revert-practice z3z3z3z] feat: commit Z - implement system healthcheck
 1 file changed, 1 insertion(+)

# Review history
$ git log --oneline
z3z3z3z (HEAD -> lab-revert-practice) feat: commit Z - implement system healthcheck
y2y2y2y feat: commit Y - append analytics tracking module
x1x1x1x feat: commit X - initialize core API controller
```

#### 2. Revert the Middle Commit (Commit Y)
I targeted Commit Y (`y2y2y2y`) to remove the analytics tracking, while keeping the rest of the changes intact.
```bash
# Revert commit Y
$ git revert y2y2y2y --no-edit
[lab-revert-practice r4r4r4r] Revert "feat: commit Y - append analytics tracking module"
 1 file changed, 1 deletion(-)
```
*(Note: `--no-edit` bypasses the text editor prompt and accepts Git's default revert message).*

#### 3. Audit Git History and Verify the Workspace State
Let's check if Commit Y is still present in the log and see how the file looks:
```bash
# Check git log
$ git log --oneline
r4r4r4r (HEAD -> lab-revert-practice) Revert "feat: commit Y - append analytics tracking module"
z3z3z3z feat: commit Z - implement system healthcheck
y2y2y2y feat: commit Y - append analytics tracking module
x1x1x1x feat: commit X - initialize core API controller

# Inspect the server.js file to verify changes
$ cat server.js
const coreApi = () => { console.log('Core Loaded'); };
const health = () => { return 'OK'; };
```
> [!IMPORTANT]
> **Observation:** Commit Y (`y2y2y2y`) is **fully preserved in the commit history**. However, the code added in Commit Y (the tracking function) has been cleanly removed from `server.js` by the new revert commit (`r4r4r4r`), while the core API (Commit X) and the healthcheck endpoint (Commit Z) remain untouched.

---

### ❓ Conceptual Q&A: Git Revert

#### 1. How is `git revert` different from `git reset`?
* **`git reset`** moves the branch HEAD pointer backward in history, physically erasing newer commits from the branch log (a history-rewriting operation).
* **`git revert`** creates a **brand-new commit** that applies the exact inverse changes of a target commit. The existing history is left completely intact, and no commits are removed.

#### 2. Why is revert considered "safer" than reset for shared branches?
Because `git revert` only **appends new commits** to the branch, it never rewrites history. Since it maintains a linear, forward-moving timeline, other developers can safely pull the change without conflicts or duplicate histories.

#### 3. When would you use revert vs reset?
* **Use Revert**: When you discover a bug in code that has **already been pushed and shared** on main/production branches. Revert allows you to undo the bug safely while preserving a clear audit trail.
* **Use Reset**: When working on **local, unpushed branches** where you want to clean up intermediate errors, squash local progress, or wipe out private experimental failures.

---

## ⚖️ Task 3: Git Reset vs Git Revert — Comprehensive Comparison

The following table summarizes the functional differences between `git reset` and `git revert` for daily DevOps workflows:

| Evaluation Dimension | `git reset` | `git revert` |
| :--- | :--- | :--- |
| **Primary Action** | Moves the active branch pointer (`HEAD`) backward in time. | Appends a new "counter-commit" that undoes changes. |
| **Impact on Git History** | **Rewrites History.** Removes or orphans commits from the log. | **Preserves History.** Keeps all historical commits intact. |
| **Staging Area Impact** | `--soft` keeps changes staged; `--mixed` & `--hard` clear them. | Creates a new staged commit instantly (or pauses for conflict). |
| **Working Directory Impact** | `--hard` wipes modifications; `--soft` & `--mixed` preserve them. | Cleanly modifies files to apply the inverse changes. |
| **Shared Branch Safety** | ❌ **Extremely Dangerous.** Will cause history divergence. |  **Safe.** Standard forward-only commit flow. |
| **Best Suited For...** | Cleaning up local, private branch commits before pushing. | Undoing faulty features on shared `main` or release branches. |

---

## 🏗️ Task 4: Industry Branching Strategies Blueprint

Branching strategies determine how engineering teams isolate and coordinate development. Below is an architectural breakdown of the three primary Git branching strategies.

---

### 1. GitFlow Strategy

**GitFlow** is a structured branching model designed for products with formal release cycles. It relies on two long-running branches (`main` and `develop`) and three types of short-lived branches (`feature`, `release`, and `hotfix`).

#### Workflow Diagram
```text
  main     ======================= [v1.0.0] ==================== [v1.1.0] =====
                                      ^                            ^
  hotfix                              |---- [hotfix/1.0.1] --------|
                                     /                              \
  release                           /----------- [release/1.1.0] ----|
                                   /            ^
  develop  === o === o =========== o =========== o ==================
                \     \                         /
  feature        \     \-- [feature/search] ---/
                  \-- [feature/login] --------/
```

* **When to use**: Best for enterprise software, legacy applications, and teams managing formal, scheduled release versions where extensive QA testing is required before deployments.
* **Pros**:
  * Clear separation of duties and stable releases.
  * Allows parallel development of new features and active hotfixes.
* **Cons**:
  * Highly complex and slow; overhead of managing multiple branch merges is high.
  * Can lead to significant integration conflicts ("merge hell") when merging long-lived release branches back into `develop`.

---

### 2. GitHub Flow Strategy

**GitHub Flow** is a lightweight, agile-friendly branching model designed for continuous delivery. It utilizes a single permanent branch (`main`) and short-lived feature branches that are merged via Pull Requests.

#### Workflow Diagram
```text
  main     ======================= o ======================== o ===========
                                  / \                       /
  feature/login                  /   o === o === o (PR) ===/
                                /
  feature/payment              /=== o === o (PR) ==========================
```

* **When to use**: Best for startups, SaaS products, web applications, and teams practicing continuous integration and continuous deployment (CI/CD) where features are shipped to production immediately upon completion.
* **Pros**:
  * Extremely simple and fast; minimal branching overhead.
  * Promotes rapid feedback loops via Pull Requests and code reviews.
* **Cons**:
  * The permanent branch (`main`) must be kept in a deployable state at all times.
  * Lacks a dedicated environment (like GitFlow's `develop`) for staging multiple features together before release.

---

### 3. Trunk-Based Development (TBD) Strategy

In **Trunk-Based Development**, all developers commit directly to a single central branch called the "Trunk" (usually `main`), or work in very short-lived feature branches (merged within 24 hours). Teams rely on **Feature Flags** to isolate incomplete features in production.

#### Workflow Diagram
```text
  main (Trunk)  ==== o ==== o ==== o ==== o ==== o ==== o ==== o ====
                      \    / \    / \    / \    / \    /
  short-lived branch   o==o   o==o   o==o   o==o   o==o  (Merged < 24 Hours)
```

* **When to use**: Best for high-velocity engineering organizations, mature dev teams, and microservices architectures aiming for continuous deployment multiple times a day.
* **Pros**:
  * Minimizes merge pain by encouraging small, frequent integrations.
  * Prevents drift between local codebases and the main repository.
* **Cons**:
  * Requires a highly mature team and robust automated testing suites (CI) to prevent broken code from hitting production.
  * Requires discipline in using **Feature Flags** (toggles) to hide unfinished work.

---

### ❓ Strategic Decisions & Real-World Selection

#### 1. Which strategy would you use for a startup shipping fast?
I would recommend **GitHub Flow** or **Trunk-Based Development**. 
* **Reasoning:** Startups need to maximize speed and minimize operational overhead. GitHub Flow allows engineers to rapidly build, get feedback via PRs, and ship features directly to production without navigating the complex web of merges required by GitFlow.

#### 2. Which strategy would you use for a large team with scheduled releases?
I would recommend **GitFlow** (or a hybrid version of Trunk-Based Development with dedicated **Release Branches**).
* **Reasoning:** A large team with scheduled releases needs structured environments for stability and validation. GitFlow provides dedicated `release` branches where QA engineers can harden the release candidate while the rest of the developers continue merging new features into the `develop` branch without causing disruptions.

#### 3. Which one does your favorite open-source project use?
* **Project Analyzed:** **Kubernetes** (`kubernetes/kubernetes`)
* **Strategy Used:** Kubernetes utilizes a highly organized variant of **Trunk-Based Development with Release Branches**. 
  * **How it works:** Developers submit all modifications to the master branch (`main`) via pull requests. When a release cycle approaches, a dedicated release branch is branched off (e.g., `release-1.30`). Bug fixes are cherry-picked from the main branch into the release branch as needed, keeping development and releases separate and stable.

---

## 📊 Visual Verification & Git Graph Dashboard

Here is a visual log of how our branches look after performing the hands-on Reset and Revert labs:

```text
* r4r4r4r (HEAD -> lab-revert-practice) Revert "feat: commit Y - append analytics tracking module"
* z3z3z3z feat: commit Z - implement system healthcheck
* y2y2y2y feat: commit Y - append analytics tracking module
* x1x1x1x feat: commit X - initialize core API controller
|
| * b2b2b2b (lab-reset-practice) feat: commit B - implement primary navigation bar
| * a1a1a1a feat: commit A - initialize index page structure
|/
* c0c0c0c (main) docs: update project roadmap
```

### Verified Terminal Activity Screenshot:
Below is the screenshot showing the successful execution of the Git Reset and Git Revert operations:

![Git Reset vs Revert Console Verification](git_reset_revert_screenshot.png)

---

Day 25 Complete 📝

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*