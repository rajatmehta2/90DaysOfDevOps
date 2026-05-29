# 👥 Day 09: Linux User & Group Management Challenge

> **"In enterprise Linux systems, secure identity isolation and granular access control are the cornerstones of infrastructure reliability and security. Mastering user provisioning, supplementary group assignments, and directory permission boundaries is essential to maintaining multi-tenant safety and implementing robust DevSecOps practices."**

Welcome to Day 09 of the **90 Days of DevOps** challenge! Today's practice is focused on **Linux User & Group Management**. In this lab, we dive deep into user creation, automated credentials provisioning, supplementary group membership configurations, and setting up secure collaborative shared directories with strict permission matrices to ensure team separation.

---

## 📋 Practice Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Linux Identity & Access Management (IAM) |
| **Operating System** | Ubuntu Server / Debian Linux |
| **Users Configured** | `tokyo`, `berlin`, `professor`, `nairobi` |
| **Groups Configured** | `developers`, `admins`, `project-team` |
| **Directories Configured** | `/opt/dev-project`, `/opt/team-workspace` |
| **Tools / Commands** | `useradd`, `chpasswd`, `groupadd`, `usermod`, `chmod`, `chgrp`, `id`, `tail` |
| **Practice Date** | May 25, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-09/` |

---

## 🗺️ User, Group, and Directory Access Architecture

The diagram below represents the exact relationship mapped out between the system users, group associations, and permissions applied over the shared target directories:

```mermaid
flowchart TD
    subgraph Users [System Users]
        U_tokyo["tokyo (Developer)"]
        U_berlin["berlin (Dev & Admin)"]
        U_prof["professor (Admin Only)"]
        U_nairobi["nairobi (Team Member)"]
    end

    subgraph Groups [Security Groups]
        G_dev["developers (Group)"]
        G_adm["admins (Group)"]
        G_team["project-team (Group)"]
    end

    subgraph Directories [Shared Workspaces]
        D_dev["/opt/dev-project (rwxrwxr-x / 775)"]
        D_team["/opt/team-workspace (rwxrwxr-x / 775)"]
    end

    %% Memberships
    U_tokyo -->|Member of| G_dev
    U_tokyo -->|Member of| G_team
    U_berlin -->|Member of| G_dev
    U_berlin -->|Member of| G_adm
    U_prof -->|Member of| G_adm
    U_nairobi -->|Member of| G_team

    %% Directory Access Controls
    G_dev -->|Group Owner (Read/Write)| D_dev
    G_team -->|Group Owner (Read/Write)| D_team

    %% Permission Restrictions (Simulated failures)
    U_prof -.->|Access Denied (Not in developers)| D_dev
    U_berlin -.->|Access Denied (Not in project-team)| D_team
```

---

## 📑 Table of Contents
1. [👤 Part 1: User Accounts Provisioning](#-part-1-user-accounts-provisioning)
   - [Step 1: Create Users with Home Directories](#step-1-create-users-with-home-directories)
   - [Step 2: Automate Password Provisioning](#step-2-automate-password-provisioning)
   - [Step 3: Verification of Accounts & Homedirs](#step-3-verification-of-accounts--homedirs)
2. [👥 Part 2: Security Groups Management](#-part-2-security-groups-management)
   - [Step 1: Create Group Containers](#step-1-create-group-containers)
   - [Step 2: Verification of System Groups](#step-2-verification-of-system-groups)
3. [🤝 Part 3: Assigning Users to Groups](#-part-3-assigning-users-to-groups)
   - [Step 1: Configure Supplementary Group Memberships](#step-1-configure-supplementary-group-memberships)
   - [Step 2: Verify Group Membership Status](#step-2-verify-group-membership-status)
4. [📂 Part 4: Secure Shared Project Directory](#-part-4-secure-shared-project-directory)
   - [Step 1: Create Directory Infrastructure](#step-1-create-directory-infrastructure)
   - [Step 2: Apply Group Ownership](#step-2-apply-group-ownership)
   - [Step 3: Apply Granular Numeric Permissions](#step-3-apply-granular-numeric-permissions)
   - [Step 4: Test Write Permissions & Access Control](#step-4-test-write-permissions--access-control)
5. [🏢 Part 5: Cross-Functional Team Workspace](#-part-5-cross-functional-team-workspace)
   - [Step 1: Provision Nairobi and Project Team Group](#step-1-provision-nairobi-and-project-team-group)
   - [Step 2: Establish and Secure Team Workspace](#step-2-establish-and-secure-team-workspace)
   - [Step 3: Verify Collaborative Write and Separation](#step-3-verify-collaborative-write-and-separation)
6. [📊 Day 09 Commands Cheatsheet](#-day-09-commands-cheatsheet)
7. [🛠️ Troubleshooting & Permission Analysis](#️-troubleshooting--permission-analysis)
8. [🧠 What I Learned](#-what-i-learned)
9. [📢 Learn in Public & Community Engagement](#-learn-in-public--community-engagement)

---

## 👤 Part 1: User Accounts Provisioning

### Step 1: Create Users with Home Directories
First, we provisioned three distinct user accounts representing different team members using the `useradd` command with the `-m` flag to generate local home directories.

```bash
sudo useradd -m tokyo
sudo useradd -m berlin
sudo useradd -m professor
```
* **Why:** The `-m` flag is essential. It tells Linux to generate a default user home directory structure (under `/home/<username>`) copied from the template configuration directory `/etc/skel`. Without it, users are created without active home paths, breaking local interactive logins.

---

### Step 2: Automate Password Provisioning
To assign user passwords efficiently without manual prompt interaction, we leveraged system pipe automation:

```bash
echo "tokyo:tokyo123" | sudo chpasswd
echo "berlin:berlin123" | sudo chpasswd
echo "professor:prof123" | sudo chpasswd
```
* **Why:** Standard `passwd` command requires typing and verifying passwords interactively. Utilizing `chpasswd` combined with pipeline output allows DevOps engineers to batch-set passwords non-interactively, perfect for infrastructure setup automation and shell scripting workflows.

---

### Step 3: Verification of Accounts & Homedirs
To ensure the accounts and directories were generated cleanly:

1. **Verify user entries in passwd db:**
   ```bash
   tail -n 3 /etc/passwd
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="449" height="99" alt="Verify User Accounts in /etc/passwd" src="https://github.com/user-attachments/assets/c39a8c0e-3a70-4f1d-80c3-3819e2015e40" />
     </p>

2. **Verify physical home directory directories:**
   ```bash
   ls -la /home
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="564" height="179" alt="Verify home directories" src="https://github.com/user-attachments/assets/5885dc50-4956-4bd0-a622-438ebf6c1c53" />
     </p>

---

## 👥 Part 2: Security Groups Management

### Step 1: Create Group Containers
To group our users logically for shared resource access, we created two system groups matching our operational teams:

```bash
sudo groupadd developers
sudo groupadd admins
```
* **Why:** Group-based permissions allow system administrators to assign directory and file access policies collectively to teams instead of handling permissions individually per user, making server governance maintainable.

---

### Step 2: Verification of System Groups
We verified that the newly constructed groups exist in the local groups configuration database:

```bash
grep -E "developers|admins" /etc/group
```
* **Terminal Verification:**
  <p align="left">
    <img width="603" height="116" alt="Verify created groups" src="https://github.com/user-attachments/assets/476c1c22-38b8-43c8-a02c-8eac334f911a" />
  </p>

---

## 🤝 Part 3: Assigning Users to Groups

### Step 1: Configure Supplementary Group Memberships
With our users and groups initialized, we mapped them according to security policies:
* `tokyo` is added to the `developers` group.
* `berlin` (a hybrid technical manager) is added to both `developers` and `admins`.
* `professor` (the coordinator) is assigned exclusively to the `admins` group.

```bash
sudo usermod -aG developers tokyo
sudo usermod -aG developers,admins berlin
sudo usermod -aG admins professor
```
* **Why:** The `-aG` flags are critical. `-G` specifies supplementary groups, and `-a` ensures the groups are **appended** to the user’s current profile. Omitting `-a` will remove the user from any other existing supplementary groups.

---

### Step 2: Verify Group Membership Status
We audited the ID structures of each user to ensure group associations are mapped perfectly:

1. **Audit User `tokyo`:**
   ```bash
   id tokyo
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="613" height="68" alt="Verify ID tokyo" src="https://github.com/user-attachments/assets/55365e9a-cded-493e-8ef7-14f90045ce24" />
     </p>

2. **Audit User `berlin`:**
   ```bash
   id berlin
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="756" height="62" alt="Verify ID berlin" src="https://github.com/user-attachments/assets/b6916e5c-6abc-480a-805e-94310b22d375" />
     </p>

3. **Audit User `professor`:**
   ```bash
   id professor
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="696" height="66" alt="Verify ID professor" src="https://github.com/user-attachments/assets/ca8d7dac-cbcd-45e6-ad9c-a2c8aeedb567" />
     </p>

---

## 📂 Part 4: Secure Shared Project Directory

### Step 1: Create Directory Infrastructure
We created a dedicated shared workspace directory in our `/opt` file system layer:

```bash
sudo mkdir -p /opt/dev-project
```
* **Why:** The `/opt` directory is designed for add-on enterprise application software and shared software bundles. Organizing project shares here separates user home folders from production workspaces.

---

### Step 2: Apply Group Ownership
We shifted the group owner of the folder to the developers:

```bash
sudo chgrp developers /opt/dev-project
```
* **Why:** By default, directories created by `root` belong to the `root` group. Changing the group owner to `developers` allows us to target this group specifically for directory modifications.

---

### Step 3: Apply Granular Numeric Permissions
We applied permission policies over `/opt/dev-project` using absolute octal modeling:

```bash
sudo chmod 775 /opt/dev-project
ls -ld /opt/dev-project
```
* **Why:** A permission setting of `775` (represented by `drwxrwxr-x`) guarantees that the creator (`root`) has full control (`7` / `rwx`), members belonging to the group owner `developers` have write access to collaborate (`7` / `rwx`), while the public/others can only read or traverse directory files (`5` / `r-x`).
* **Terminal Verification:**
  <p align="left">
    <img width="598" height="119" alt="Verify directory permissions" src="https://github.com/user-attachments/assets/bb2f96e2-c12a-4e19-b3af-1f555cdd9761" />
  </p>

---

### Step 4: Test Write Permissions & Access Control
To ensure isolation works correctly, we simulated real-world file execution as different system identities using the non-interactive switch shell `sudo su <username> -c`:

1. **Verify Developer Write access (`tokyo`):**
   ```bash
   sudo su tokyo -c "touch /opt/dev-project/tokyo-file.txt"
   ```
   * **Terminal Output:**
     <p align="left">
       <img width="760" height="23" alt="tokyo file creation success" src="https://github.com/user-attachments/assets/6de4f0d6-eba6-4e3b-93e4-8192543a64cf" />
     </p>

2. **Verify Hybrid Admin/Developer Write access (`berlin`):**
   ```bash
   sudo su berlin -c "touch /opt/dev-project/berlin-file.txt"
   ```
   * **Terminal Output:**
     <p align="left">
       <img width="775" height="21" alt="berlin file creation success" src="https://github.com/user-attachments/assets/c05f80e2-e75f-4efd-9e81-f4923f93415d" />
     </p>

3. **Verify Non-Developer Access Restriction (`professor`):**
   Since `professor` does not belong to the group owner `developers`, attempts to write inside `/opt/dev-project` must be rejected by the kernel.
   ```bash
   sudo su professor -c "touch /opt/dev-project/prof-file.txt"
   ```
   * **Terminal Output:**
     <p align="left">
       <img width="793" height="76" alt="professor permission denied" src="https://github.com/user-attachments/assets/79facadf-8974-4b13-a74f-97f0e6881b59" />
     </p>
     * *Success: The Linux kernel correctly enforced permission security and blocked the transaction with a `Permission denied` error.*

---

## 🏢 Part 5: Cross-Functional Team Workspace

### Step 1: Provision Nairobi and Project Team Group
Next, we simulated setting up a distinct project team workspace for a new cross-functional initiative:

1. **Create User `nairobi`:**
   ```bash
   sudo useradd -m nairobi
   echo "nairobi:nai123" | sudo chpasswd
   ```
2. **Create Group `project-team`:**
   ```bash
   sudo groupadd project-team
   ```
3. **Map Workspace Collaborators:**
   Add both `nairobi` and our original developer `tokyo` into the new `project-team` container.
   ```bash
   sudo usermod -aG project-team nairobi
   sudo usermod -aG project-team tokyo
   ```

---

### Step 2: Establish and Secure Team Workspace
We initialized a dedicated filesystem area for team-workspace documents:

```bash
sudo mkdir -p /opt/team-workspace
sudo chgrp project-team /opt/team-workspace
sudo chmod 775 /opt/team-workspace
```
* **Why:** Configures `/opt/team-workspace` to allow shared collaborative work exclusively between members of the `project-team` group, keeping other system users isolated from team work.

---

### Step 3: Verify Collaborative Write and Separation
Finally, we tested the new security sandbox boundary:
* `nairobi` (Member) -> Should write files successfully.
* `tokyo` (Member) -> Should write files successfully.
* `berlin` (Non-member) -> Should fail to write files with "Permission denied".

```bash
sudo su nairobi -c "touch /opt/team-workspace/nairobi-file.txt"
sudo su tokyo -c "touch /opt/team-workspace/tokyo-team-file.txt"
sudo su berlin -c "touch /opt/team-workspace/berlin-fail.txt"
```
* **Terminal Verification:**
  <p align="left">
    <img width="838" height="330" alt="Team workspace access verification" src="https://github.com/user-attachments/assets/22ac13bd-0af3-4619-b79f-39fc5c2f6d05" />
  </p>
  * *Result: `nairobi` and `tokyo` successfully created files. `berlin` was blocked by the kernel. The network boundary was validated.*

---

## 📊 Day 09 Commands Cheatsheet

| Command | Category | Purpose |
| :--- | :--- | :--- |
| `useradd -m <username>` | Account Provisioning | Instantiates a new system user profile along with home folder hierarchies |
| `echo "user:pass" \| chpasswd` | Password Control | Automates setting user credentials in a non-interactive pipe pipeline |
| `groupadd <group>` | Privilege Control | Generates a new system logical group container |
| `usermod -aG <group> <user>` | Group Assignment | Appends a supplementary security group mapping onto an existing user |
| `mkdir -p <directory>` | Directory Management | Creates path folders recursively avoiding error codes if directories exist |
| `chgrp <group> <path>` | Ownership Management | Changes the primary group assignment of target directories or files |
| `chmod <mode> <path>` | Security Policy | Re-configures operational read/write/execute permissions using octal models |
| `id <username>` | Audit & Verification | Outputs primary and supplementary user identification metadata |
| `grep <pattern> /etc/group` | Infrastructure Audit | Scans the system group database file to track active group entries |
| `sudo su <user> -c "cmd"` | Shell Simulation | Runs one-off CLI commands while adopting alternative user shell profiles |

---

## 🛠️ Troubleshooting & Permission Analysis

### 1. The Importance of the `-a` Append Flag in `usermod`
* **Common Mistake:** Running `usermod -G devs tokyo` instead of `usermod -aG devs tokyo`.
* **The Danger:** If `tokyo` was already part of another group (e.g., `project-team`), omitting `-a` (append) overwrites their security group array, dropping the user from `project-team` completely.
* **Resolution Rule:** Always double-check group assignment scripts and ensure the `-aG` flags are bundled together to append rather than replace.

### 2. Standard "Permission Denied" During Directory Test
* **Common Root Cause:** When running multi-user simulation commands like `sudo su <username> -c "touch /opt/dev-project/file"`, the transaction fails if parent directory permissions are too restrictive (e.g., `700`) or group owner boundaries are configured improperly.
* **Troubleshooting Step:** Run `ls -ld <target-directory>` to audit permission flags (`drwxrwxr-x`) and ownership blocks (`root developers`), verifying the target user belongs to the matching group before executing files.

---

## 🧠 What I Learned

1. **Automation-Friendly Credentialing:** Discovered the power of `chpasswd` over `passwd` when automating multiple user accounts setups inside initialization shell scripts.
2. **Supplemental Group Security Mapping:** Learned how supplemental group mappings allow system administrators to grant multi-group memberships to users (e.g. `berlin` being both developer and admin).
3. **Directory Access and Boundaries Isolation:** Configured real-world shared directories (`775` octal modes) and verified that the kernel correctly rejects non-authorized users, establishing multi-tenant safety.

---

## 📢 Learn in Public & Community Engagement

### 🎓 Share Progress
I am sharing my progress for the **#90DaysOfDevOps** challenge! Let's connect on LinkedIn:

* **Today's Key Focus:** Configured Linux user accounts, created security groups, mapped nested permissions, and validated directory sandboxes.
* **Securing Assets Rule of Thumb:** Use group permissions (`775`) to allow developers to collaborate safely while restricting foreign system accounts.
* **Join the Journey on LinkedIn:**
  * `#90DaysOfDevOps`
  * `#DevOpsKaJosh`
  * `#TrainWithShubham`

---
**TrainWithShubham** | Day 09 Complete 🚀
