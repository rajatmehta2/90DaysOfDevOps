# 🛡️ Day 49 – DevSecOps: Add Security to Your CI/CD Pipeline

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub--Actions-blue?style=for-the-badge&logo=github-actions)](https://github.com/)
[![DevSecOps Secured](https://img.shields.io/badge/DevSecOps-Trivy--Scanned-success?style=for-the-badge&logo=aquasecurity)](https://github.com/)
[![GitHub Security](https://img.shields.io/badge/Secret--Scanning-Enabled-brightgreen?style=for-the-badge&logo=github)](https://github.com/)

---

## 📖 Introduction to DevSecOps

In modern software delivery, automated CI/CD pipelines allow us to build, test, and deploy software at breakneck speeds. However, velocity without security is a recipe for disaster. **DevSecOps (Development, Security, and Operations)** is the practice of integrating automated security checks, vulnerability scanning, and compliance testing directly into the CI/CD pipeline rather than treating security as an afterthought or a final gateway. 

By automating these checks, security issues are caught **early** (shifting security to the left), making vulnerabilities cheap and straightforward to resolve before they ever make it into a production environment.

---

## 🎯 Key DevSecOps Principles

> [!IMPORTANT]
> 1. **Shift Left:** Don't wait for production. Scan and verify code, dependencies, and containers at the pull request level to resolve issues within minutes.
> 2. **Continuous Security Automation:** Automate every security check so they execute on every push, pull request, and build. Do not rely on human memory.
> 3. **Fail-Fast & Block:** Treat security alerts like broken tests. If a critical or high vulnerability is found, fail the build and prevent deployment.
> 4. **Secret Scanning & Prevention:** Never commit secrets (API keys, passwords, database URIs) to your repository. Enforce automated scanning and active push protection.
> 5. **Enforce Least Privilege:** Workflows and runner agents must have the minimum permission set required to perform their specific tasks.

---

## 📐 DevSecOps Pipeline Architecture

Here is the secure end-to-end pipeline structure implemented today. Every phase of our DevOps workflow is now guarded by automated security scanners.

```mermaid
graph TD
    %% Define Styles
    classDef dev fill:#1f77b4,stroke:#333,stroke-width:2px,color:#fff;
    classDef sec fill:#d62728,stroke:#333,stroke-width:2px,color:#fff;
    classDef ops fill:#2ca02c,stroke:#333,stroke-width:2px,color:#fff;
    classDef trigger fill:#e377c2,stroke:#333,stroke-width:2px,color:#fff;

    subgraph Development [Development Phase]
        A[Developer Action: Git Push / PR Open]:::dev
    end

    subgraph SecurityShield [Continuous Security & Protection]
        SP[GitHub Push Protection]:::sec -->|Secret Detected?| SP_Fail[Block Git Push]:::sec
        SP -->|Clean Push| B(GitHub Repository):::dev
        GSS[GitHub Secret Scanning]:::sec -.->|Real-time Monitor| B
    end

    subgraph PR_Workflow [Pull Request Pipeline]
        PR_Trigger[Trigger: PR Opened]:::trigger --> PR_Build[Build & Test]:::dev
        PR_Build --> PR_DepScan[Dependency Review Scan <br/> actions/dependency-review-action]:::sec
        PR_DepScan -->|Vulnerabilities Found| PR_Fail[Fail PR Check & Block Merge]:::sec
        PR_DepScan -->|All Checks Pass| PR_Success[PR Approved for Merge]:::ops
    end

    subgraph Main_Workflow [Main Pipeline - Deployment]
        Main_Trigger[Trigger: Merge to main]:::trigger --> Main_Build[Build & Test]:::dev
        Main_Build --> Main_DockBuild[Docker Build]:::dev
        Main_DockBuild --> Main_Trivy[Trivy Image Scan <br/> aquasecurity/trivy-action]:::sec
        Main_Trivy -->|Critical/High Vulnerability| Trivy_Fail[Fail Pipeline & Halt Push]:::sec
        Main_Trivy -->|No Critical Issues| Main_DockPush[Docker Push to Registry]:::ops
        Main_DockPush --> Main_Deploy[Automated Deployment]:::ops
    end

    A --> SP
    B -->|Triggers PR Workflow| PR_Trigger
    PR_Success -->|Merged to main| Main_Trigger

    class A,B,PR_Build,Main_Build,Main_DockBuild dev;
    class SP,SP_Fail,GSS,PR_DepScan,PR_Fail,Main_Trivy,Trivy_Fail sec;
    class PR_Success,Main_DockPush,Main_Deploy ops;
    class PR_Trigger,Main_Trigger trigger;
```

---

## 🛠️ Challenge Tasks

### Task 1: Scan Your Docker Image for Vulnerabilities (Trivy)

To verify that our container images do not introduce operating system or package-level vulnerabilities, we integrate **Aqua Security's Trivy** into our main pipeline. If Trivy finds any `CRITICAL` or `HIGH` severity vulnerabilities, it exits with code `1`, immediately halting the deployment.

#### 1. Workflow Configuration Update (`.github/workflows/main.yml`)

Add this step to your main pipeline after building the Docker image but *before* pushing it to Docker Hub:

```yaml
      # Build the Docker image locally
      - name: Build Docker Image
        run: |
          docker build -t ${{ secrets.DOCKER_HUB_USERNAME }}/node-app:${{ github.sha }} -t ${{ secrets.DOCKER_HUB_USERNAME }}/node-app:latest .

      # Scan the Docker image using Aqua Security Trivy
      - name: Scan Docker Image for Vulnerabilities (Trivy)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.DOCKER_HUB_USERNAME }}/node-app:latest'
          format: 'table'
          exit-code: '1' # Fails the pipeline run if vulnerabilities are found matching the severity
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'
```

#### 2. Mock Terminal Logs: Vulnerabilities Found (Fail Run)

If the base image contains high/critical vulnerabilities (e.g., using a legacy version of `node:18`), Trivy blocks the push:

```bash
2026-06-02T16:15:32.412Z [INFO] 🛡️ Initializing Trivy Docker Image Scanner...
2026-06-02T16:15:32.905Z [INFO] 📦 Pulling image metadata: rajatmehta9/node-app:latest
2026-06-02T16:15:34.110Z [INFO] 🔍 Scanning container image for vulnerabilities (Severity: HIGH,CRITICAL)...

rajatmehta9/node-app:latest (debian 11.7)
=========================================
Total: 3 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 2, CRITICAL: 1)

┌───────────────┬────────────────┬──────────┬───────────────────┬───────────────┬──────────────────────────────────────────────┐
│    Library    │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │                    Title                     │
├───────────────┼────────────────┼──────────┼───────────────────┼───────────────┼──────────────────────────────────────────────┤
│ openssl       │ CVE-2023-5363  │ CRITICAL │ 3.0.9-1           │ 3.0.9-2       │ openssl: incorrect cipher selection bug      │
├───────────────┼────────────────┼──────────┼───────────────────┼───────────────┼──────────────────────────────────────────────┤
│ zlib          │ CVE-2023-45853 │ HIGH     │ 1.2.11.dfsg-2+deb │ 1.2.11.dfsg-3 │ zlib: integer overflow in miniunz            │
├───────────────┼────────────────┼──────────┼───────────────────┼───────────────┼──────────────────────────────────────────────┤
│ libcrypto3    │ CVE-2023-5678  │ HIGH     │ 3.0.9-1           │ 3.0.10-1      │ openssl: cryptographic weakness in DH        │
└───────────────┴────────────────┴──────────┴───────────────────┴───────────────┴──────────────────────────────────────────────┘

❌ Error: Trivy scanned 3 vulnerabilities with exit-code 1 (Filtered: HIGH, CRITICAL)
Error: Process completed with exit code 1.
```

#### 3. Mock Terminal Logs: Vulnerability Resolved (Pass Run)

By changing our base image to a lean, secure version (`node:20-alpine`), Trivy outputs a clean bill of health:

```bash
2026-06-02T16:20:11.104Z [INFO] 🛡️ Initializing Trivy Docker Image Scanner...
2026-06-02T16:20:11.450Z [INFO] 📦 Pulling image metadata: rajatmehta9/node-app:latest
2026-06-02T16:20:12.802Z [INFO] 🔍 Scanning container image for vulnerabilities (Severity: HIGH,CRITICAL)...

rajatmehta9/node-app:latest (alpine 3.19.1)
===========================================
Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

✅ Success: Trivy scanned 0 vulnerabilities with exit code 0!
```

#### 4. GitHub Actions Execution Screenshot

Here is the visual representation of the Trivy scanning step successfully running inside GitHub Actions:

```
┌────────────────────────────────────────────────────────────────────────┐
│ Actions > Workflows > Build and Deploy Pipeline #42                    │
├────────────────────────────────────────────────────────────────────────┤
│  🟢 Build & Test (ubuntu-latest)                              [02:14]  │
│  🟢 Build & Tag Docker Image                                  [01:05]  │
│  🟢 Scan Docker Image for Vulnerabilities (Trivy)              [00:45]  │
│     ▼ Run aquasecurity/trivy-action@master                             │
│       Trivy Image Scan Details:                                        │
│       Target: rajatmehta9/node-app:latest (alpine 3.19.1)              │
│       No vulnerabilities found. Exit code 0!                           │
│  🟢 Push Docker Image to Docker Hub                           [00:30]  │
│  🟢 Continuous Deployment to Staging                          [01:12]  │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Task 2: Enable GitHub's Built-in Secret Scanning & Push Protection

To protect secrets such as SSH keys, AWS credentials, and API keys from leaking into the repository history, we activate GitHub's built-in security features.

#### Setup Guide:
1. Navigate to the repository on GitHub.
2. Go to **Settings** → **Code security and analysis**.
3. Under **Secret scanning**, click **Enable**.
4. Enable **Push protection** to block credentials *before* they are accepted by GitHub.

---

### ❓ DevSecOps Q&A: Secrets Protection

#### 📘 What is the difference between secret scanning and push protection?
* **Secret Scanning (Post-receive):** Searches the commit history of the repository retroactively for leaked credentials. It alerts you if a secret has *already* been committed, meaning you must immediately rotate/revoke the leaked key as it is now in the Git history.
* **Push Protection (Pre-receive):** Intercepts the `git push` event in real-time. It scans the incoming changes *before* they hit the repository. If a secret is detected, GitHub **rejects the push**, preventing the credential from ever entering your remote Git history.

#### 📘 What happens if GitHub detects a leaked AWS key in your repo?
1. **Developer Block:** If Push Protection is active, the `git push` is blocked instantly, and the developer must remove the secret to push code.
2. **Immediate Alerting:** If the secret scanning catches a secret post-commit, an email and UI alert are triggered for the repository administrators.
3. **Automated Partner Notification:** For high-profile service providers like AWS, GitHub immediately forwards the leak signature to AWS. AWS will then automatically apply a temporary restrictive policy to the leaked key or disable it, notifying the owner of the AWS account to prevent active abuse.

#### 5. Push Protection Blocking Screenshot (Realistic Console Output)

```bash
$ git push origin main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 12 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 345 bytes | 345.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote: 
remote: 🛡️  GitHub Push Protection Blocked Your Push! 🛡️
remote: 
remote: GitHub detected the following secrets in commit 8f9b4ac572c:
remote: 
remote:   -- ❌ Leaked Secret Found: AWS Access Key ID -------------------
remote:      File:   config/production.env
remote:      Line:   12
remote:      Secret: AKIAIOSFODNN7XXXXXXX
remote: 
remote:   -- How to Resolve:
remote:      1. Remove the secret from your commit history:
remote:         git reset HEAD~1
remote:         (Remove the secret from your files)
remote:         git commit -a -m "Remove hardcoded credentials"
remote:      2. If this is a false positive, use the bypass link below:
remote:         https://github.com/rajatmehta9/github-actions-capstone/security/secret-scanning/bypass?key=...
remote: 
remote: To push anyway, address the secrets or bypass them, then push again.
remote: 
To github.com:rajatmehta9/github-actions-capstone.git
 ! [remote rejected] main -> main (push declined due to secret detection)
error: failed to push some refs to 'github.com:rajatmehta9/github-actions-capstone.git'
```

---

### Task 3: Scan Dependencies for Known Vulnerabilities (Dependency Review)

Open-source libraries form the foundation of most applications, but they can bring critical vulnerabilities. By implementing `actions/dependency-review-action` in our **PR workflow**, we scan package manifests (like `package.json`, `requirements.txt`, etc.) for changes and fail the PR if a dangerous dependency is introduced.

#### 1. PR Workflow Configuration (`.github/workflows/pr.yml`)

Create or update your Pull Request pipeline to include the dependency review stage:

```yaml
name: Pull Request Pipeline

on:
  pull_request:
    branches:
      - main

permissions:
  contents: read

jobs:
  build:
    name: Build, Test & Dependency Review
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install Dependencies
        run: npm ci

      - name: Run Tests
        run: npm test

      # Scan dependency changes in the PR
      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: 'critical'
```

#### 2. Mock Terminal Logs: Vulnerable Package Detected

```bash
2026-06-02T16:25:01.002Z [INFO] 🔍 Initializing Dependency Review Action...
2026-06-02T16:25:01.154Z [INFO] 📂 Reviewing dependency changes between base (main) and head (feature/add-payment-gate)...
2026-06-02T16:25:01.500Z [INFO] 📡 Fetching vulnerability database for package changes...

Dependency Review Summary:
-------------------------
❌ Failed package: axios (npm)
   - Severity: critical
   - Vulnerability ID: CVE-2023-45857
   - Description: Axios Cross-Site Request Forgery Vulnerability
   - Current Version: 1.6.0
   - Required Version: >=1.6.1

Error: Dependency Review detected 1 critical severity vulnerability.
Error: Process completed with exit code 1.
```

---

### Task 4: Workflow Permissions & Least Privilege Principle

Enforcing the least privilege principle prevents security leaks if a repository's runner or a third-party Github Action becomes compromised.

#### Workflow Permissions Block (`.github/workflows/main.yml`)

Explicitly limit token capabilities by defining a top-level `permissions` block:

```yaml
# Enforce read-only access to repository contents by default
permissions:
  contents: read
  packages: read
  security-events: write # Required if you upload SARIF logs to GitHub Security Tab
```

#### ❓ DevSecOps Q&A: Workflow Permissions

#### 📘 Why is it a good practice to limit workflow permissions?
By default, the `GITHUB_TOKEN` provided to your runner workflows can have write access to repository contents, packages, Pull Requests, and actions depending on repository settings. Restricting this to `contents: read` guarantees that even if a workflow execution environment is compromised (e.g. through a supply chain attack or arbitrary code execution), attackers cannot write malicious commits back to your codebase, override release tags, or alter environments.

#### 📘 What could go wrong if a compromised third-party Action has write access to your repo?
If a compromised or rogue action has write access:
1. **Malicious Code Injection:** It could commit and push backdoor scripts directly into your production branch.
2. **Credential Theft:** It could steal repository secrets (AWS tokens, Docker credentials) and exfiltrate them.
3. **Pipeline Poisoning:** It could alter workflow definitions to run cryptocurrency miners or bypass branch protection rules.
4. **Supply Chain Infection:** It could publish compromised npm/Docker packages to your registry, infecting downstream consumers of your software.

---

## 🌟 Brownie Points: Advanced Security Practices

### 1. Pin Actions to Commit SHAs

Using tags like `@v4` is common, but tags can be altered or hijacked by bad actors. For absolute safety in production environments, pin actions directly to the specific Git commit SHA, leaving the human-readable tag as a comment:

```yaml
# ❌ Before: Unsecured Tag
- name: Checkout Code
  uses: actions/checkout@v4

#  After: Secured Commit SHA Pinning
- name: Checkout Code
  uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

---

### 2. Upload Scan Results to GitHub Security Tab (SARIF Integration)

Instead of only outputting scanning logs to the console, configure Trivy to write standard Static Analysis Results Interchange Format (SARIF) files and upload them to GitHub's Security dashboard:

```yaml
      - name: Scan Docker Image (SARIF)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.DOCKER_HUB_USERNAME }}/node-app:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy Scan Results to GitHub Security Tab
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

---

### 3. OpenID Connect (OIDC) Keyless Authentication

Instead of storing long-lived cloud credentials (like AWS IAM User Access Keys) as static GitHub repository secrets, production systems utilize **OIDC**. 
* **How it works:** GitHub Actions act as a trusted Identity Provider (IdP). When your pipeline runs, it requests a short-lived token from AWS (STS) utilizing a JSON Web Token (JWT) authenticated by GitHub. 
* **Benefits:** This entirely eliminates static passwords/access keys, drastically shrinking the damage surface if repository secrets are ever leaked.

---

## 🎓 Day 49 Conclusion

Today we successfully added **robust security guardrails** to our CI/CD pipeline! We converted a simple, fast deployment script into a secured, professional **DevSecOps workflow**. Security scanning is now part of the pipeline's core logic: checking code push constraints, verifying dependency changes in Pull Requests, and continuously scanning Docker images for runtime exploits.

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*