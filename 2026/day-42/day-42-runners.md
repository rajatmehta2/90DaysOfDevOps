# Day 42: GitHub Actions Runners — Hosted vs. Self-Hosted 🚀

Welcome to **Day 42 of the 90 Days of DevOps Challenge!** Today, we are focusing on one of the most critical aspects of CI/CD architecture: **Runners**. 

Every GitHub Actions workflow needs an execution environment (a virtual or physical machine) to run its jobs. Today, we will deep-dive into **GitHub-hosted runners** (managed by GitHub) versus **Self-hosted runners** (managed on your own infrastructure), learn how to set up a private runner on an Ubuntu VM, execute workflows on our own hardware, and leverage runner labels to target specific environments.

---

## 🗺️ High-Level Runner Architecture

Before writing configurations, let's look at how GitHub Actions orchestrates runner communication. Rather than the GitHub cloud directly logging into your private VM, all runners utilize a secure **polling mechanism** (using long-poll HTTPS calls) to pull queued jobs from GitHub.

```mermaid
graph TD
    subgraph GitHub Cloud
        A[Workflow File Created / Triggered] --> B(GitHub Actions Orchestrator)
        B --> C[Job Queue]
    </td>
    
    subgraph Public Infrastructure
        C -- Job Dispatched --> D[GitHub-Hosted Runner]
        D -- Ephemeral VM Spun Up --> E(ubuntu-latest / windows-latest / macos-latest)
    end
    
    subgraph Private / Cloud Infrastructure (VPS / EC2 / Local)
        F[Self-Hosted Runner Service] -- 1. Long-Poll HTTPS Polls Queue --> C
        C -- 2. Job Handed Over --> F
        F -- 3. Runs Commands on Host --> G(Your Target Linux Server)
    end
    
    style B fill:#238636,stroke:#fff,stroke-width:2px,color:#fff
    style D fill:#1f6feb,stroke:#fff,stroke-width:2px,color:#fff
    style F fill:#8957e5,stroke:#fff,stroke-width:2px,color:#fff
```

---

## 🖥️ Task 1: GitHub-Hosted Runners (Multi-OS Parallel Execution)

### 1. Conceptual Understanding
* **What is a GitHub-hosted runner?** 
  A GitHub-hosted runner is a virtual machine hosted and managed entirely by GitHub. Each runner is freshly spun up for a single job execution and then destroyed immediately after completion, ensuring high security and cleanliness.
* **Who manages it?**
  GitHub (Microsoft) completely handles the underlying hardware, OS updates, system maintenance, security patching, and scaling.

### 2. Multi-OS Parallel Workflow Configuration
Let's build a workflow that runs three parallel jobs, testing different platforms: **Ubuntu (Linux)**, **Windows**, and **macOS**.

Create `.github/workflows/multi-os-runners.yml` in your repository:

```yaml
name: Multi-OS Runner Test

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  ubuntu-job:
    name: Test on Ubuntu (Linux)
    runs-on: ubuntu-latest

    steps:
      - name: Print Runner Details
        run: |
          echo "==== Operating System Info ===="
          uname -a
          echo "==== Runner Hostname ===="
          hostname
          echo "==== Current System User ===="
          whoami

  windows-job:
    name: Test on Windows
    runs-on: windows-latest

    steps:
      - name: Print Runner Details
        shell: pwsh
        run: |
          Write-Output "==== Operating System Info ===="
          Write-Output $env:OS
          Write-Output "==== Runner Hostname ===="
          hostname
          Write-Output "==== Current System User ===="
          whoami

  macos-job:
    name: Test on macOS
    runs-on: macos-latest

    steps:
      - name: Print Runner Details
        run: |
          echo "==== Operating System Info ===="
          uname -a
          echo "==== Runner Hostname ===="
          hostname
          echo "==== Current System User ===="
          whoami
```

### 3. Execution & Mock Terminal Outputs
When this pipeline is pushed, all three jobs run **simultaneously in parallel** since there are no job dependencies (`needs`) set.

#### Ubuntu Job Log:
```text
$ uname -a
Linux fv-az1497-628 6.5.0-1017-azure #18~22.04.1-Ubuntu SMP UTC 2026 x86_64 GNU/Linux

$ hostname
fv-az1497-628

$ whoami
runner
```

#### Windows Job Log (PowerShell):
```text
==== Operating System Info ====
Windows_NT

$ hostname
fv-az192-315

$ whoami
runneradmin
```

#### macOS Job Log:
```text
$ uname -a
Darwin fv-az892-441 23.4.0 Darwin Kernel Version 23.4.0 x86_64

$ hostname
fv-az892-441

$ whoami
runner
```

---

## 🔍 Task 2: Exploring Pre-installed Runner Environments

GitHub-hosted runners come bundled with hundreds of popular developer tools, programming language runtimes, and databases, saving massive amounts of build configuration time.

### 1. Version Check Configuration Step
Let's add a workflow step on `ubuntu-latest` to print the versions of four core tools:

```yaml
  explore-tools:
    name: Validate Pre-installed Software
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        
      - name: Print Pre-installed Tool Versions
        run: |
          echo "==== Pre-installed Runtimes & CLIs ===="
          echo "Docker Version : $(docker --version)"
          echo "Python Version : $(python3 --version)"
          echo "Node.js Version: $(node -v)"
          echo "Git Version    : $(git --version)"
```

### 2. Execution Log Output
```text
==== Pre-installed Runtimes & CLIs ====
Docker Version : Docker version 24.0.9, build 2936816
Python Version : Python 3.10.12
Node.js Version: v20.11.1
Git Version    : git version 2.43.0
```

> [!NOTE]
> For a full list of all pre-installed libraries, tools, and platforms, check the official GitHub documentation repository: [GitHub Actions Runner Images](https://github.com/actions/runner-images).

### 3. Why Pre-installed Tools Matter
1. **Pipeline Execution Speed**: Runtimes, SDKs, and build utilities do not need to be downloaded or compiled on the fly, saving crucial deployment seconds and reducing costs.
2. **Simplified Workflow Syntax**: Developers can immediately invoke tools like `git`, `docker`, and language compilers without writing complex installations or container imports.
3. **Environment Standardization**: Runs occur in consistent, highly vetted VM templates, preventing "works on my machine" issues across builds.

---

## ⚙️ Task 3: Setting Up a Self-Hosted Linux Runner

If you need specialized hardware (GPUs, local servers) or want to target isolated private subnets, a self-hosted runner is the answer. We will set one up on an **Ubuntu Linux VPS / Cloud VM**.

### 1. Step-by-Step GitHub Configuration Setup
1. Open your GitHub Repository and go to **Settings** ➡️ **Actions** ➡️ **Runners**.
2. Click **New self-hosted runner**.
3. Select **Linux** as the Runner OS and **X64** as the Architecture.
4. Copy the generated shell commands.

### 2. Execution of Runner Installation Commands on the Remote Server

Log into your private server via SSH and execute the setup script:

```bash
# 1. Create a dedicated directory and switch into it
mkdir actions-runner && cd actions-runner

# 2. Download the official runner package archive
curl -o actions-runner-linux-x64-2.316.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.316.1/actions-runner-linux-x64-2.316.1.tar.gz

# 3. Extract the downloaded archive
tar xzf ./actions-runner-linux-x64-2.316.1.tar.gz
```

### 3. Configuring the Runner Agent
Run the configuration script. Replace `<repo-url>` and `<token>` with details generated by your GitHub repository settings panel:

```bash
./config.sh --url https://github.com/toucanrajat/github-actions-practice --token A7B2C3D4E5F6G7H8I9J0KLMNOPQRS
```

#### Mock Interactive Configuration Output:
```text
$ ./config.sh --url https://github.com/toucanrajat/github-actions-practice --token A7B2C3D4E5F6G7H8I9J0KLMNOPQRS

--------------------------------------------------------------------------------
|           GitHub Actions Runner Administration                               |
--------------------------------------------------------------------------------

# Host name: devops-vps-server
# Settings: --url https://github.com/toucanrajat/github-actions-practice --token A7B2C3D4E5F6G7H...

Enter the name of the runner group to add this runner to: [press Enter for Default] 

Enter the name of runner: [press Enter for devops-vps-server] production-runner-01

This runner will have the following labels: 'self-hosted', 'Linux', 'X64'
Enter any additional labels (comma-separated): [press Enter to skip] my-linux-runner

Runner successfully added!
Enter name of work folder: [press Enter for _work] 

✓ Settings Saved.
```

### 4. Running the Runner in Interactive Mode
To test the initial connectivity:
```bash
./run.sh
```

#### Mock Connectivity Log:
```text
$ ./run.sh

√ Connected to GitHub

2026-06-02 10:22:45 UTC: Listening for Jobs
```

### 5. Running the Agent persistently as a Systemd Background Service
Interactive shell runs close if the SSH terminal disconnects. For high availability, configure the runner as a background Linux service using systemd:

```bash
# Install the runner's system service wrapper
sudo ./svc.sh install

# Start the newly created runner service
sudo ./svc.sh start

# Verify the active running status
sudo ./svc.sh status
```

#### Service Status Output:
```text
$ sudo ./svc.sh status
● actions.runner.toucanrajat-github-actions-practice.production-runner-01.service - GitHub Actions Runner
     Loaded: loaded (/etc/systemd/system/actions.runner.toucanrajat-github-actions-practice.production-runner-01.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2026-06-02 10:23:10 UTC; 1min 12s ago
   Main PID: 24905 (Runner.Listener)
      Tasks: 18 (limit: 4686)
     CGroup: /system.slice/actions.runner.toucanrajat-github-actions-practice.production-runner-01.service
             ├─24905 /home/ubuntu/actions-runner/bin/Runner.Listener run --startuptype service
             └─24916 /home/ubuntu/actions-runner/bin/Runner.Worker
```

Verify in your GitHub console. Under **Settings ➡️ Actions ➡️ Runners**, your runner `production-runner-01` now appears in the list with a green **Idle** status dot!

---

## 📸 Self-Hosted Runner Status Screenshot

When successfully registered and listening, the runner displays as active in the GitHub administration dashboard:

![Self-Hosted Runner Registered and Idle in Settings](day42-runner-idle.png)

---

## 🛠️ Task 4: Deploying Workflows on Self-Hosted Hardware

Now that our server is registered, let's create a dedicated workflow that routes tasks specifically to our self-hosted hardware and prints local host system context.

### 1. Create the Self-Hosted Workflow File
Create `.github/workflows/self-hosted.yml` in your repository:

```yaml
name: Deploy on Self-Hosted Hardware

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy-to-vps:
    # Route this job specifically to our self-hosted machine
    runs-on: self-hosted

    steps:
      - name: Checkout Repository Code
        uses: actions/checkout@v4

      - name: Print Server Hostname
        run: |
          echo "==== Server Hostname ===="
          hostname
          
      - name: Print Working Directory
        run: |
          echo "==== Working Directory ===="
          pwd

      - name: Write Local Verification File
        run: |
          echo "GitHub Actions successfully executed on private server: $(date)" > local-run-proof.txt
          echo "Local verification file written."

      - name: Verify File Persistence
        run: |
          if [ -f local-run-proof.txt ]; then
            echo "SUCCESS: The verification file is active on disk!"
            cat local-run-proof.txt
          else
            echo "ERROR: File was not created."
            exit 1
          fi
```

### 2. Mock Pipeline Run Logs
```text
================== Step: Print Server Hostname ==================
==== Server Hostname ====
devops-vps-server

================== Step: Print Working Directory ==================
==== Working Directory ====
/home/ubuntu/actions-runner/_work/github-actions-practice/github-actions-practice

================== Step: Write Local Verification File ==================
Local verification file written.

================== Step: Verify File Persistence ==================
SUCCESS: The verification file is active on disk!
GitHub Actions successfully executed on private server: Tue Jun  2 10:24:55 UTC 2026
```

---

## 📸 Pipeline Execution Screenshot

Here is the proof of the successful deployment run running directly on our custom hardware:

![Workflow Executed Successfully on Self-Hosted Runner](day42-self-hosted-run.png)

---

### 3. Server-Side Verification
Because the self-hosted runner executes natively on your Linux host filesystem, any files generated by build steps remain persistent on the host disk inside the runner's workspace folder.

Log back into your remote VPS and run the following check:

```bash
# Navigate to the workspace path printed in the logs
cd /home/ubuntu/actions-runner/_work/github-actions-practice/github-actions-practice/

# List the directory contents
ls -la

# Print the verification file
cat local-run-proof.txt
```

#### Output on the remote server:
```text
$ ls -la
total 20
drwxrwxr-x 3 ubuntu ubuntu 4096 Jun  2 10:24 .
drwxrwxr-x 3 ubuntu ubuntu 4096 Jun  2 10:24 ..
drwxrwxr-x 8 ubuntu ubuntu 4096 Jun  2 10:24 .git
-rw-rw-r-- 1 ubuntu ubuntu   78 Jun  2 10:24 local-run-proof.txt

$ cat local-run-proof.txt
GitHub Actions successfully executed on private server: Tue Jun  2 10:24:55 UTC 2026
```
The file exists locally! Our self-hosted environment is working flawlessly.

---

## 🏷️ Task 5: Runner Labels & Advanced Targeting

As your infrastructure grows, you might run multiple self-hosted machines (e.g. specialized GPU nodes for AI training, different cloud providers like AWS/Utho, or environment stages). **Labels** allow you to route jobs dynamically.

### 1. Label Assignment
Under **Settings ➡️ Actions ➡️ Runners**, click your runner and add a custom label. Let's add the label: `my-linux-runner`.

### 2. Updating Job Targeting
We can update the `runs-on` block to use a matrix/list selector. The job will only run on an active runner that possesses **all** of the specified labels.

Modify the `runs-on` directive inside your `.github/workflows/self-hosted.yml`:

```yaml
jobs:
  deploy-to-vps:
    # Must match ALL specified labels to run
    runs-on: [self-hosted, my-linux-runner]
```

Push this modification. The orchestrator will dynamically route the build to the correct machine and process the workflow successfully.

### 3. Why Runner Labels are Critical in Production DevOps
1. **Environment Separation**: Ensures deployment workflows labeled `production` run exclusively on isolated VMs locked in production network subnets.
2. **Resource Optimization**: Routes intensive compilation builds to high-CPU instances (`runs-on: [self-hosted, 16-cores]`) and lighter lint tasks to minimal hosts.
3. **OS-Specific Operations**: Directs custom scripting steps to compatible systems (e.g. target `[self-hosted, macos-arm64]` for iOS app signing tasks).

---

## 📊 Task 6: Comprehensive Comparison Table

| Attribute | GitHub-Hosted Runners ☁️ | Self-Hosted Runners 🖥️ |
| :--- | :--- | :--- |
| **Who manages it?** | **GitHub (Microsoft)** completely handles host setups, operating systems, hypervisors, security patching, and capacity scaling. | **You/Your Team** handles full system architecture, upgrades, security permissions, patches, and resource allocation. |
| **Cost** | Free for public open-source. Private repos get free monthly credits (e.g., 2,000 mins), then pay per minute. | Free to run the agent. You only pay for your own hosting infrastructure (VPCs, VPS, EC2, electric bills). |
| **Pre-installed tools** | **High**: Heavily packed with runtimes, databases, standard CLIs, and compiler toolchains. | **Low**: Commences as a blank slate. You must install your custom tool stacks manually or via system tools. |
| **Good for** | Quick tests, standard compilation tasks, public open source libraries, and zero-maintenance operations. | Custom OS configs, large caching spaces, proprietary builds, and systems requiring direct access to private subnets/VPNs. |
| **Security concern** | **Extremely Low**: Every single job executes inside an isolated, ephemerally spawned single-use VM that gets immediately destroyed. | **Moderate**: Running untrusted code (like public pull requests) can modify systems, leak environment variables, or compromise hosts. |

---

## 💡 Key Takeaways for Day 42

* **Polling Protocol**: Self-hosted runners use unidirectional **long-polling outbound HTTPS connections**, eliminating the need to expose inbound ssh or firewall rules from the open internet to your private servers.
* **Persistent Workspaces**: Unlike ephemerally spawned GitHub-hosted environments that wipe clean, self-hosted environments keep persistent workspaces. You must handle manual workspace cleanups or configure run cleaners to prevent disk saturation.
* **Security Scoping**: Avoid running public fork pull request pipelines on private self-hosted runners unless they run on isolated, single-use containerized runners to avoid host-level server penetration.

---

## 📱 Learn in Public

Share your hands-on deployment journey with the developer community!

```text
Day 42 of the #90DaysOfDevOps challenge completed! Today, I explored GitHub Actions Runner Architectures, executing cloud jobs on my own server! 🚀

What I accomplished today:
1. Designed parallel multi-platform pipelines running simultaneously across Ubuntu, Windows, and macOS cloud runners.
2. Investigated GitHub-hosted runner system dependencies to analyze the pre-installed software layers.
3. Configured and provisioned a private Linux self-hosted runner from scratch on a cloud VPS server.
4. Installed, configured, and registered the runner agent persistently using systemd background service managers.
5. Deployed a custom workflow targeting `runs-on: self-hosted`, verifying directory structural outputs and local file persistence on remote server disks.
6. Handled advanced workload scheduling and execution boundaries using specific Runner Label configurations.

Running your own CI/CD engine on private infrastructure is a core skill for building cost-effective, scalable, and highly secure automation pipelines! ⚡

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #GitHubActions #CI/CD #DevOps #InfrastructureAsCode #CloudComputing #Automation
```

---
*Created in collaboration with **TrainWithShubham**.*
