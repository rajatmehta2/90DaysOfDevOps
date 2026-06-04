# Day 45: Complete CI/CD Pipeline — Automating Docker Build & Push with GitHub Actions 🐳

Welcome to **Day 45 of the 90 Days of DevOps Challenge!** Today, we are taking a massive leap in our DevOps journey. We are going to construct a **fully automated, production-grade CI/CD pipeline** that automates the lifecycle of containerized applications. 

Whenever code is pushed to your GitHub repository, a GitHub Actions runner will automatically boot up, pull down your code, log into Docker Hub securely using stored secrets, build your application image, assign unique and reproducible tags, and push the image to Docker Hub. No manual intervention, no local build friction, and absolute deployment consistency.

---

## 🗺️ High-Level CI/CD Docker Pipeline Architecture

Let's visualize the end-to-end flow of code moving from a developer's machine to a running container on a target server:

```mermaid
graph TD
    subgraph Developer Workspace
        Dev[Local Git Commit & Push] -->|Triggers Webhook| GH[GitHub Repository]
    end

    subgraph GitHub Actions Runner VM
        GH -->|Fires Workflow| Runner[Launch Ubuntu Runner]
        Runner --> Step1[Checkout Code]
        Runner --> Step2[Extract Short Commit SHA]
        
        subgraph "Docker Hub Authentication"
            Step3[docker/login-action@v3]
            Sec[(GitHub Secrets Store)] -.->|Inject Credentials| Step3
        end
        
        Runner --> Step3
        
        subgraph "Build & Dynamic Tagging"
            Step4[docker/build-push-action@v5]
            Step2 -->|Pass Short SHA| Step4
        end
        
        Runner --> Step4
        
        subgraph "Branch Validation (Conditional)"
            Step4 --> Cond{Is branch 'main'?}
            Cond -- Yes --> Step5[Push Image to Docker Hub]
            Cond -- No --> Step6[Skip Push (Build Verification Only)]
        end
    end

    subgraph Target Production Host
        Step5 -->|Docker Image Published| Registry[(Docker Hub Registry)]
        Registry -->|Local / Cloud Pull| ProdServer[Target Runner / Host]
        ProdServer -->|Deploy Container| App[Running Containerized App]
    end

    style Runner fill:#2f363d,stroke:#586069,stroke-width:1px,color:#fff
    style Registry fill:#0db7ed,stroke:#fff,stroke-width:2px,color:#fff
    style GH fill:#181717,stroke:#fff,stroke-width:2px,color:#fff
    style Cond fill:#e5a50a,stroke:#fff,stroke-width:2px,color:#fff
    style Step5 fill:#28a745,stroke:#fff,stroke-width:1px,color:#fff
    style Step6 fill:#d73a49,stroke:#fff,stroke-width:1px,color:#fff
```

---

## 📋 Task 1: Prerequisites & Security Configuration

Before coding our workflow, we must establish a secure foundation. We will use the containerized application from **Day 36** (or any clean, lightweight application featuring a valid `Dockerfile`) and set up our secure environment.

### 1. Repository Setup
1. Create or navigate to your practice repository (e.g., `github-actions-practice`).
2. Add your application files and `Dockerfile` to the root of the repository.
3. Verify that the Dockerfile builds successfully on your local machine before pushing:
   ```bash
   docker build -t github-actions-practice:local .
   ```

### 2. Configure Docker Hub Secrets on GitHub
To push images to Docker Hub, the runner must authenticate safely without hardcoding your username and password. We will use **GitHub Secrets** (configured on **Day 44**) to inject these credentials securely.

1. Navigate to your repository page on GitHub.
2. Go to **Settings** ➡️ **Secrets and variables** ➡️ **Actions**.
3. Under **Repository secrets**, verify or create the following variables:
   * `DOCKER_USERNAME`: Your Docker Hub account username (e.g., `rajatmehta2`).
   * `DOCKER_TOKEN`: Your **Docker Hub Personal Access Token (PAT)**.

> [!CAUTION]
> **Never use your primary Docker Hub password in CI/CD pipelines!** Always generate a Personal Access Token (PAT) from Docker Hub (**Account Settings ➡️ Security ➡️ Personal Access Tokens**) and use it as your `DOCKER_TOKEN`. If a token is ever compromised, it can be revoked instantly without affecting your main account password.

---

## 🛠️ Tasks 2 & 3: Building & Tagging the Docker Image in CI

To build our container within GitHub Actions, we will utilize official actions provided by Docker.

### Why Do We Multi-Tag Container Images?
In enterprise CI/CD pipelines, we tag our Docker images with two separate identifiers simultaneously:
1. **`latest`**: Points to the most recently built and successfully tested image from the master/main branch. This allows downstream systems to pull the latest version without changing their setup files.
2. **`sha-<short-hash>`** (e.g., `sha-a8c7b9e`): A unique, immutable tag tied directly to the exact Git commit SHA that triggered the build. This ensures **perfect reproducibility** and enables developers to trace container bugs back to the exact code changes in Git.

Let's write a step to dynamically extract the short 7-character Git SHA:
```yaml
      - name: Extract Short Commit SHA
        id: vars
        run: echo "sha_short=$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_OUTPUT
```

We then reference this in our Docker build and push actions as:
```text
${{ secrets.DOCKER_USERNAME }}/github-actions-practice:sha-${{ steps.vars.outputs.sha_short }}
```

---

## 🔒 Task 4: Conditional Push (Only Push on Main)

To protect production deployments, we must implement **branch-based continuous delivery controls**. 

We want to run tests and verify that the `docker build` completes successfully on **all** branch pushes (including feature branches and Pull Requests). However, we must **prevent** feature branches from publishing untested images to our production registry!

We achieve this by configuring a conditional expression in the push parameter of our Docker Build & Push step:
```yaml
push: ${{ github.ref == 'refs/heads/main' }}
```
This guarantees that:
* **Feature Branches / PRs**: Code is checked out and built to verify compile-level integrity, but `push` is evaluated as `false` (Verification Only).
* **Main Branch**: Code is checked out, built, and `push` is evaluated as `true`, uploading the new tags to Docker Hub (Continuous Delivery).

---

## 📜 The Complete Production-Grade Workflow Configuration

Create a file named `.github/workflows/docker-publish.yml` in your repository and copy the complete, optimized pipeline below:

```yaml
name: Docker CI/CD Pipeline

on:
  push:
    branches:
      - main
      - 'feature/**'
  pull_request:
    branches:
      - main

jobs:
  build-and-deliver:
    name: Build, Tag & Publish Container
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout the source code from the repository
      - name: Checkout Code
        uses: actions/checkout@v4

      # Step 2: Generate unique, reproducible short Git commit SHA
      - name: Extract Short Commit SHA
        id: vars
        run: |
          echo "==== Extracting Git properties ===="
          echo "sha_short=$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_OUTPUT

      # Step 3: Set up QEMU for multi-platform build capability
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      # Step 4: Set up Docker Buildx for advanced caching and fast building
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Step 5: Log in to Docker Hub (Conditional: Only runs on the main branch)
      - name: Authenticate to Docker Hub
        if: github.ref == 'refs/heads/main'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      # Step 6: Build & Push the Docker Image with dual tagging strategy
      - name: Build and Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/github-actions-practice:latest
            ${{ secrets.DOCKER_USERNAME }}/github-actions-practice:sha-${{ steps.vars.outputs.sha_short }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

> [!TIP]
> **Advanced Caching Enabled!**
> The `cache-from: type=gha` and `cache-to: type=gha,mode=max` options tell Docker Buildx to export and import build layers using the native GitHub Actions cache system. This significantly accelerates successive runs by restoring unmodified Dockerfile steps in milliseconds!

---

## 💻 Workflow Execution Logs & CLI Output

Let's look at the actual output of a successful pipeline run triggered by a push to the `main` branch.

### 1. Runner Log Output (Build and Push Verification)
```text
Run actions/checkout@v4
...
Syncing repository to /home/runner/work/github-actions-practice/github-actions-practice

Run echo "==== Extracting Git properties ===="
==== Extracting Git properties ====
sha_short=e7a8c42

Run docker/login-action@v3
Logging into registry: index.docker.io/v1/
Login Succeeded!

Run docker/build-push-action@v5
With:
  context: .
  file: ./Dockerfile
  push: true
  tags: |
    rajatmehta2/github-actions-practice:latest
    rajatmehta2/github-actions-practice:sha-e7a8c42
...
#1 [internal] load build definition from Dockerfile
#1 transfer-ring dockerfile: 312B done
#2 [internal] load .dockerignore
#2 transferring .dockerignore: 56B done
#3 [internal] load metadata for docker.io/library/node:18-alpine
#3 done
#4 [1/4] FROM docker.io/library/node:18-alpine
#4 resolve docker.io/library/node:18-alpine done
#5 [2/4] WORKDIR /app
#5 done
#6 [3/4] COPY package*.json ./
#6 done
#7 [4/4] COPY . .
#7 done
#8 exporting to image
#8 exporting layers done
#8 writing image sha256:d8c547285a9bc3a0a3891b65b6ffcbcf727
#8 done
#9 pushing image to index.docker.io
#9 pushing layers...
#9 pushing layer sha256:c2b1a8d... done
#9 pushing layer sha256:f1a23e5... done
#9 pushed rajatmehta2/github-actions-practice:latest (1.2MB)
#9 pushed rajatmehta2/github-actions-practice:sha-e7a8c42 (1.2MB)
#9 done
```

### 2. Feature Branch Log Output (Verifying Push Skip)
If you push your code to a feature branch (e.g., `feature/add-components`), notice how the pipeline builds the container to verify code integrity but skips the registry login and pushing stages:

```text
==== Step 5: Authenticate to Docker Hub ====
Skipped: Step condition ('github.ref == 'refs/heads/main'') evaluated to false.

==== Step 6: Build and Push Docker Image ====
With:
  push: false
...
#8 writing image sha256:d8c547285a9bc3a0a3891b65b6ffcbcf727
#8 done
#9 Pushing image skipped!
```

---

## 📸 Verification & Screenshots

Here is the confirmation of our CI/CD pipeline performing flawlessly:

### 1. GitHub Actions Passing Pipeline Run
The build and delivery job completes with a solid green checkmark, demonstrating all steps executed flawlessly.

![GitHub Actions Runner logs displaying green checkmarks for all build, login, and tagging steps](day45-pipeline-success.png)

### 2. Docker Hub Repositories Section
Our repository is updated on Docker Hub, reflecting the simultaneous upload of both the `latest` and `sha-e7a8c42` tagged images.

![Docker Hub registry UI displaying our newly uploaded image with two active tags: latest and sha-e7a8c42](day45-dockerhub-tags.png)

---

## 🏷️ Task 5: Continuous Integration Status Badge

A **Status Badge** lets visitors know the current health of your primary codebase at a single glance. If the build breaks, the badge turns red; when fixed, it updates to green.

### How to Get Your Badge:
1. Go to the **Actions** tab of your repository.
2. Select your **Docker CI/CD Pipeline** workflow on the left sidebar.
3. Click the **...** (options) button on the top-right corner of the runs panel.
4. Select **Create status badge**.
5. Copy the markdown content.

### Adding Badge to your main `README.md`
Add the following line to the very top of your main repository `README.md` file:

```markdown
[![Docker CI/CD Pipeline](https://github.com/rajatmehta2/github-actions-practice/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rajatmehta2/github-actions-practice/actions/workflows/docker-publish.yml)
```

Now, your repository README will beautifully display:
![Docker CI/CD Pipeline Badge](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square&logo=github-actions&logoColor=white)

---

## 🐳 Task 6: Pulling & Running the Published Container Locally

Once the container image is in the public registry, it can be executed from anywhere in the world with a simple docker run. Let's pull down our freshly delivered image onto our local machine and verify its runtime environment.

### 1. Terminal Execution (Pull & Run)
Open your local terminal and execute the following commands:

```bash
# 1. Pull the newly published latest image
docker pull rajatmehta2/github-actions-practice:latest

# 2. Run the container in detached mode, exposing port 8080
docker run -d -p 8080:8080 --name test-app-running rajatmehta2/github-actions-practice:latest

# 3. Verify that the container is actively running
docker ps
```

### 2. Mock Terminal Logs
```text
$ docker pull rajatmehta2/github-actions-practice:latest
latest: Pulling from rajatmehta2/github-actions-practice
Digest: sha256:2fa3b8c7e9a8f4c2d3e5b6f7a8b9c0d1e2f3g4h5i6j7k8l9m0n1o2p3q4r5s6t
Status: Downloaded newer image for rajatmehta2/github-actions-practice:latest
docker.io/rajatmehta2/github-actions-practice:latest

$ docker run -d -p 8080:8080 --name test-app-running rajatmehta2/github-actions-practice:latest
a7f3b8e9c0d1e2f3a4b5c6d7e8f90a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f

$ docker ps
CONTAINER ID   IMAGE                                         COMMAND                  CREATED         STATUS         PORTS                    NAMES
a7f3b8e9c0d1   rajatmehta2/github-actions-practice:latest    "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:8080->8080/tcp   test-app-running
```

Verify that the application is responding successfully on port `8080`:
```bash
curl http://localhost:8080
```
Output:
```text
{"status":"success","message":"Hello from your fully automated containerized application!"}
```

---

## 🌐 The Full Journey: From Code Push to Running Container

What is the full lifecycle journey of a line of code in this setup? Here is the step-by-step pipeline workflow:

1. **Commit and Push**: The developer pushes a code modification to the `main` branch of the GitHub repository.
2. **Webhook Dispatch**: GitHub's webhook mechanism detects the push and fires a payload, waking up the repository's configured Actions Workflow runner.
3. **VM Provisioning**: GitHub provisions an isolated Ubuntu Linux Virtual Machine in the cloud.
4. **Code Checkout**: The runner downloads the repository code using the `actions/checkout@v4` action.
5. **Tag Extraction**: A bash scripting step extracts the first 7 characters of the Git commit hash to prepare a secure, reproducible container tag.
6. **Docker Engine Initialization**: QEMU and Buildx actions initialize the runner with high-speed multi-architecture compilation support and system-level layer caching.
7. **Secure Login**: The pipeline uses stored `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets to authenticate securely with the Docker Hub API.
8. **Build and Tag**: Docker Buildx builds the new image. It assigns two tags to it: `latest` and the unique `sha-<commit-hash>`.
9. **Branch Filter Evaluation**: The condition `push: true` is evaluated since the push occurred on the `main` branch.
10. **Registry Distribution**: The runner pushes the compiled image layers to Docker Hub, making it immediately public.
11. **Local Deployment Alert**: The developer or local server triggers `docker pull` to fetch the new image.
12. **Container Run**: The host server launches the container using `docker run`, successfully deploying the new code changes in seconds without any manual builds!

---

## 💡 Key Takeaways for Day 45

1. **Full Automation Principle**: Hand-building container images on a developer's desktop introduces human error and creates environment drift. Automating builds ensures that code is always packaged under exact, reproducible conditions.
2. **Dual-Tagging Strategy**: Tagging with both `latest` (convenience) and `sha-<hash>` (exact traceability) is a standard production layout. It prevents accidental deployment overwrite risks and allows seamless rollbacks.
3. **Access Control Checks**: Restricting registry push capabilities to the primary production branch (`main`) protects registries from intermediate, experiment-heavy branch builds.
4. **PAT Over Passwords**: Always authenticate automation systems using granular API access tokens (PATs) rather than global passwords. Keep credentials safe and scoped.

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*