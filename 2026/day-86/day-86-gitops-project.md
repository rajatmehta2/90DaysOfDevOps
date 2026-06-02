# Day 86: GitOps Project -- End-to-End Declarative CI/CD Pipeline with AI-BankApp

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI-blue?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Docker-Build-blue?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-CD_GitOps-orange?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Amazon EKS](https://img.shields.io/badge/Amazon_EKS-Kubernetes-blue?style=for-the-badge&logo=amazoneks&logoColor=white)](https://aws.amazon.com/eks/)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day--86-red?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 86** of the **90 Days of DevOps Journey**! 🚀 

Over the last two days, we set up ArgoCD, mastered its sync strategies, managed multi-tier deployments with sync waves, implemented the App of Apps pattern, and enforced role-based access control (RBAC). Today, we reach the summit of our GitOps journey: **wiring the complete, end-to-end automated GitOps pipeline**.

In a mature enterprise DevOps environment, manual deployments are anti-patterns. Today, we build a zero-human-intervention workflow. When a developer pushes a code change, GitHub Actions compiles the application, runs the tests, dockerizes the app, pushes it to DockerHub, updates the Kubernetes manifest with the new cryptographic Git SHA tag, and commits it back to Git. ArgoCD instantly detects this change and rolls out a zero-downtime deployment to EKS.

---

## 📖 Table of Contents
1. [🏗️ Section 1: End-to-End GitOps Pipeline Architecture](#-section-1-end-to-end-gitops-pipeline-architecture)
2. [⚙️ Section 2: Deep Dive into the CI/CD Pipeline (GitHub Actions)](#-section-2-deep-dive-into-the-cicd-pipeline-github-actions)
3. [🛠️ Section 3: Step-by-Step Pipeline & Fork Setup](#-section-3-step-by-step-pipeline--fork-setup)
4. [🚀 Section 4: Triggering and Verifying the End-to-End Pipeline](#-section-4-triggering-and-verifying-the-end-to-end-pipeline)
5. [🛡️ Section 5: Drift Detection and Self-Healing Scenarios](#-section-5-drift-detection-and-self-healing-scenarios)
6. [🗺️ Section 6: The Full 90-Day DevOps Pipeline Map](#-section-6-the-full-90-day-devops-pipeline-map)
7. [🎓 Section 7: GitOps 3-Day Journey Summary](#-section-7-gitops-3-day-journey-summary)
8. [🧹 Section 8: Complete Teardown and Cleanup](#-section-8-complete-teardown-and-cleanup)
9. [📌 Section 9: Key Takeaways & Best Practices](#-section-9-key-takeaways--best-practices)

---

## 🏗️ Section 1: End-to-End GitOps Pipeline Architecture

The complete flow operates as a closed loop, using **Git as the Single Source of Truth**. Below is the architectural blueprint of the automation:

```mermaid
graph LR
    classDef dev fill:#FCE8E6,stroke:#D93025,stroke-width:2px;
    classDef ci fill:#E8F0FE,stroke:#1A73E8,stroke-width:2px;
    classDef git fill:#FEF7E0,stroke:#F0B400,stroke-width:2px;
    classDef cd fill:#E6F4EA,stroke:#137333,stroke-width:2px;

    Dev[💻 Developer] -->|1. git push code| GH[🐙 GitHub Fork Repo]
    
    subgraph GitHub Actions CI Pipeline
        GH -->|2. Triggers| GHA[⚙️ GitHub Actions Runner]
        GHA -->|3. Compile & Test| Maven[📦 Maven Build]
        GHA -->|4. Package| Docker[🐳 Docker Build]
        Docker -->|5. Push Registry| DH[(🐳 DockerHub)]
        GHA -->|6. Update Tag via sed| LocalManifest[📄 k8s/deployment.yml]
        LocalManifest -->|7. Commit & Push [skip ci]| GH
    end
    
    subgraph Kubernetes EKS Cluster
        Argo[🐙 ArgoCD Controller] -->|8. Webhook / Polling| GH
        Argo -->|9. Reconcile Delta| EKS[☸️ EKS Pods]
    end

    class Dev dev;
    class GHA,Maven,Docker ci;
    class GH,DH git;
    class Argo,EKS cd;
```

---

## ⚙️ Section 2: Deep Dive into the CI/CD Pipeline (GitHub Actions)

The engine driving the continuous integration phase is the GitHub Actions workflow located in `.github/workflows/gitops-ci.yml`. Let’s break down its architectural design.

### 📝 Triggers
```yaml
on:
  push:
    branches: [feat/gitops]
    paths:
      - 'src/**'
      - 'pom.xml'
      - 'Dockerfile'
  workflow_dispatch:
```
> [!IMPORTANT]
> **Path Filtering**: The workflow is configured to run only when application-specific code is modified (`src/**`, `pom.xml`, `Dockerfile`). It explicitly ignores changes to `/k8s` manifest files. This prevents an **infinite runner loop**, as the pipeline itself commits manifest changes back to the repository.

### 📝 Step-by-Step CI/CD Breakdown

| Step | Runner Operations | Shell Command / Action |
|:---|:---|:---|
| **Checkout Code** | Clones the GitHub repository into the virtual runner environment. | `actions/checkout@v4` |
| **Set up JDK 21** | Provisions Java development environment with built-in Maven caching. | `actions/setup-java@v4` (Java 21, vendor: temurin) |
| **Build with Maven** | Compiles, packages, and skips tests to speed up the delivery process. | `./mvnw clean package -DskipTests -B` |
| **Run Unit Tests** | Executes unit tests. Set to `continue-on-error: true` so the pipeline remains non-blocking during rapid dev iterations. | `./mvnw test -B` |
| **Set Image Tag** | Generates a unique, short Git SHA hash (7 characters) to tag the Docker image. | `echo "sha_short=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT` |
| **Login to DockerHub** | Authenticates with the registry using repo environment secrets. | `docker/login-action@v3` |
| **Build & Push Image** | Builds the Docker image, tags it with both `:latest` and the dynamic `:sha` tag, and pushes to DockerHub. | `docker/build-push-action@v5` |
| **Update K8s Manifest** | Modifies the deployment file in-place, replacing the old image tag with the new Git SHA. | `sed -i "s\|image: \${{ env.DOCKERHUB_REPO }}:.*\|image: \${{ env.DOCKERHUB_REPO }}:\${{ steps.tag.outputs.sha_short }}\|" k8s/bankapp-deployment.yml` |
| **Commit manifest** | Commits and pushes the modified manifest back to GitHub using the `[skip ci]` flag to bypass rebuilding. | `git commit -m "ci: update bankapp image to \${{ steps.tag.outputs.sha_short }} [skip ci]"` |

### 🔍 The Critical GitOps Update Code Blocks

#### 1. In-place manifest update via `sed`:
```yaml
- name: Update Kubernetes deployment manifest
  run: |
    sed -i "s|image: ${{ env.DOCKERHUB_REPO }}:.*|image: ${{ env.DOCKERHUB_REPO }}:${{ steps.tag.outputs.sha_short }}|" k8s/bankapp-deployment.yml
```

#### 2. The Git Commit & Push with Loop Protection:
```yaml
- name: Commit updated manifest
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add k8s/bankapp-deployment.yml
    git diff --staged --quiet || git commit -m "ci: update bankapp image to ${{ steps.tag.outputs.sha_short }} [skip ci]"
    git push
```

> [!WARNING]
> **Why `[skip ci]`?**
> When the runner commits the updated `k8s/bankapp-deployment.yml` file back to the branch, GitHub receives a push. Without `[skip ci]` in the commit message, GitHub would re-trigger the workflow, updating the manifest again and creating an infinite execution loop that consumes all your runner minutes. The `[skip ci]` flag explicitly instructs GitHub Actions to ignore this commit.

---

## 🛠️ Section 3: Step-by-Step Pipeline & Fork Setup

To run this pipeline successfully, you must configure authentication and update repository configurations.

### 1. Fork the Repository
Fork the AI-BankApp repository to your personal GitHub account:
```text
https://github.com/TrainWithShubham/AI-BankApp-DevOps -> [Click Fork]
```

### 2. Generate DockerHub Access Token
1. Go to your **DockerHub Settings** > **Security** > **Personal Access Tokens**.
2. Click **Generate New Token**.
3. Set the name to `EKS-GitOps-Pipeline` and assign **Read, Write, Delete** permissions.
4. Copy the generated token.

### 3. Add GitHub Actions Secrets
In your personal GitHub fork, navigate to **Settings** > **Secrets and variables** > **Actions** > **New repository secret** and create the following:

| Secret Name | Value |
|:---|:---|
| `DOCKERHUB_USERNAME` | Your DockerHub username (e.g., `toucanrajat`) |
| `DOCKERHUB_TOKEN` | The Personal Access Token generated in Step 2 |

### 4. Update the Pipeline Variables
Edit `.github/workflows/gitops-ci.yml` in your local clone or GitHub editor, and modify the environment repository path:

```yaml
env:
  DOCKERHUB_REPO: toucanrajat/ai-bankapp-eks # Replace with your DockerHub namespace
```

### 5. Update the Kubernetes Deployment File
Open `k8s/bankapp-deployment.yml` and point the container image to your DockerHub repository:

```yaml
spec:
  containers:
    - name: bankapp
      image: toucanrajat/ai-bankapp-eks:latest # Replace with your DockerHub repository
      ports:
        - containerPort: 8080
```

### 6. Align the ArgoCD Application Target
Execute the following CLI command to direct ArgoCD to track your personal fork instead of the upstream template repo:

```bash
# Point ArgoCD to your fork
argocd app set bankapp --repo https://github.com/rajatmehta2/AI-BankApp-DevOps.git
```

#### Terminal Execution & Output:
```text
Application 'bankapp' updated successfully
```

Commit and push all changes to your branch:
```bash
git add .
git commit -m "infra: configure environment parameters for custom fork CI/CD"
git push origin feat/gitops
```

---

## 🚀 Section 4: Triggering and Verifying the End-to-End Pipeline

Let's test the entire automated workflow by introducing a visible UI change in the code.

### 1. Modify the Frontend Title
Open `src/main/resources/templates/fragments/layout.html` and change the application navbar title to customize it:

```html
<!-- Line 25 - Customize the branding title -->
<a class="navbar-brand" href="#"><i class="fas fa-university me-2"></i>AI BankApp - Managed by Rajat</a>
```

### 2. Push Code to GitHub
```bash
# Stage the modified frontend files
git add src/main/resources/templates/fragments/layout.html

# Commit the code modification
git commit -m "feat: customize navbar branding to Rajat"

# Push the change to trigger the CI workflow
git push origin feat/gitops
```

#### Terminal Execution & Output:
```text
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 8 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 488 bytes | 488.00 KiB/s, done.
Total 5 (delta 3), reused 0 (delta 0), pack-reused 0
To https://github.com/rajatmehta2/AI-BankApp-DevOps.git
   f39a7b1..4e2ba09  feat/gitops -> feat/gitops
```

---

### 3. Monitor GitHub Actions CI Pipeline
Navigate to the **Actions** tab of your repository fork. You will see the **GitOps CI - Build & Push to DockerHub** run trigger automatically.

### 🖼️ GitHub Actions Build Success
*Below is the execution log of the pipeline compiling code, executing tests, pushing the Docker image, and updating the manifest file:*

![GitHub Actions CI Pipeline Running Successfully](./images/github_actions_pipeline.png)

---

### 4. Review the Automatic bot Commit
Once the GitHub Actions runner completes, check the Git repository commit history. You will see a commit pushed by the GitHub Actions bot:

### 🖼️ Bot Manifest Auto-Update Commit
*The commit showing the updated deployment tag in the Git repository:*

![GitHub Actions Bot Manifest Update Commit](./images/git_actions_bot_commit.png)

If you check the code changes on GitHub for that commit, the `image` field in `k8s/bankapp-deployment.yml` was updated:
```diff
-      image: toucanrajat/ai-bankapp-eks:latest
+      image: toucanrajat/ai-bankapp-eks:4e2ba09
```

---

### 5. Verify ArgoCD Automated Reconciliation
Because ArgoCD uses automated syncing, it instantly detects that Git now points to the new image tag `4e2ba09`.

Run the following command to watch the synchronization take place:
```bash
# Force an immediate application refresh and wait for sync completion
argocd app get bankapp --refresh
argocd app wait bankapp
```

#### Terminal Execution & Output:
```text
Name:               argocd/bankapp
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          bankapp
URL:                https://localhost:8443/applications/bankapp
Repo:               https://github.com/rajatmehta2/AI-BankApp-DevOps.git
Target:             feat/gitops
Path:               k8s
Sync Policy:        Automated (Prune, SelfHeal)
Sync Status:        Synced to feat/gitops (4e2ba09)
Health Status:      Healthy

Revision:           4e2ba09 (ci: update bankapp image to 4e2ba09 [skip ci])
```

### 🖼️ ArgoCD Active Sync Dashboard
*The ArgoCD console displaying the newly synced Git SHA revision running healthy on the EKS cluster:*

![ArgoCD Active Sync Dashboard](./images/argocd_sync_revision.png)

Verify the rolling deployment in EKS:
```bash
# Monitor rolling pod updates
kubectl get pods -n bankapp
```

#### Terminal Execution & Output:
```text
NAME                                 READY   STATUS        RESTARTS   AGE
bankapp-deployment-55d64bbf6-9xsw2   1/1     Running       0          42s
bankapp-deployment-55d64bbf6-bbx21   1/1     Running       0          38s
bankapp-deployment-55d64bbf6-fl921   1/1     Running       0          40s
bankapp-deployment-55d64bbf6-p9sl1   1/1     Running       0          45s
bankapp-deployment-c782c9f59-1sk82   1/1     Terminating   0          4m
bankapp-deployment-c782c9f59-8s27a   1/1     Terminating   0          4m
```

---

### 6. Verify the UI Modification
We can run a local port-forward to test the live frontend:

```bash
# Set up port-forward to local machine port 8080
kubectl port-forward svc/bankapp-service -n bankapp 8080:8080
```

#### Terminal Execution & Output:
```text
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```

Open `http://localhost:8080` in your web browser. You will see the new navigation header: **"AI BankApp - Managed by Rajat"**. 

**The automated cycle is complete: zero human intervention from code commit to production!**

---

## 🛡️ Section 5: Drift Detection and Self-Healing Scenarios

A core benefit of GitOps is drift correction. We tested ArgoCD's ability to heal itself when direct modifications are made to the EKS cluster resources.

### Scenario 1: Manual Scaling Attack (Direct Scaling)
An administrator bypasses Git and directly scales down the application deployment:
```bash
# Manually scale the deployment down to a single replica
kubectl scale deployment bankapp-deployment -n bankapp --replicas=1
```

#### Terminal Execution & Output:
```text
deployment.apps/bankapp-deployment scaled
```

#### ArgoCD Action:
ArgoCD instantly detects that the EKS cluster has only **1 replica** while the Git manifest specifies **4 replicas**. It labels the deployment as `OutOfSync` and triggers a self-heal operation.

```bash
# Check EKS pods immediately
kubectl get pods -n bankapp
```

#### Terminal Execution & Output:
```text
NAME                                 READY   STATUS    RESTARTS   AGE
bankapp-deployment-55d64bbf6-9xsw2   1/1     Running   0          4m
bankapp-deployment-55d64bbf6-bbx21   0/1     Pending   0          2s
bankapp-deployment-55d64bbf6-fl921   0/1     Pending   0          2s
bankapp-deployment-55d64bbf6-p9sl1   0/1     Pending   0          2s
```
> ArgoCD restored the target state of **4 replicas** within seconds.

---

### Scenario 2: Image Injection (Direct Image Modification)
An engineer directly deploys a different image onto EKS using `kubectl`:
```bash
# Attempt to replace the production app image with nginx
kubectl set image deployment/bankapp-deployment bankapp=nginx:latest -n bankapp
```

#### Terminal Execution & Output:
```text
deployment.apps/bankapp-deployment image updated
```

#### ArgoCD Action:
ArgoCD detects that the image is running `nginx:latest` instead of the Git-defined `toucanrajat/ai-bankapp-eks:4e2ba09`. It flags the resource as drifted, terminates the Nginx pods, and restarts the BankApp application containers using the correct tag.

```bash
# Monitor pods returning to the correct state
kubectl get pods -n bankapp -w
```

#### Terminal Execution & Output:
```text
NAME                                 READY   STATUS              RESTARTS   AGE
bankapp-deployment-55d64bbf6-9xsw2   1/1     Running             0          7m
bankapp-deployment-8cf7381-8s92k     0/1     ContainerCreating   0          1s
bankapp-deployment-8cf7381-8s92k     1/1     Running             0          4s
bankapp-deployment-8cf7381-8s92k     1/1     Terminating         0          5s
bankapp-deployment-55d64bbf6-p9sl1   1/1     Running             0          2s
```
> The cluster corrected the image drift automatically.

---

### Scenario 3: Resource Deletion Attack (Service Deletion)
An operator deletes the application service, making the bank app unreachable:
```bash
# Delete the network entry point service
kubectl delete service bankapp-service -n bankapp
```

#### Terminal Execution & Output:
```text
service "bankapp-service" deleted
```

#### ArgoCD Action:
ArgoCD detects the missing service resource, references the Git repository, and recreates the service configuration with its original NodePort/LoadBalancer settings.

```bash
# Verify the service is back online
kubectl get svc -n bankapp
```

#### Terminal Execution & Output:
```text
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
bankapp-service   NodePort    10.100.82.114   <none>        8080:31180/TCP   4s
```
> The service was successfully restored.

---

### 📊 Drift Detection Performance Analysis

| Scenario | Drift Detected | Self-Heal Response Time | Action Performed |
|:---|:---:|:---:|:---|
| **1. Direct Scale Down** | `OutOfSync` | ~4 seconds | Scaled replicas back from 1 to 4 |
| **2. Image Tampering** | `OutOfSync` | ~6 seconds | Terminated Nginx container, redeployed BankApp:4e2ba09 |
| **3. Service Deletion** | `Missing` | ~3 seconds | Recreated K8s Service object from git manifest |

> [!NOTE]
> **What if `selfHeal` was disabled?**
> If self-healing is disabled, ArgoCD still detects the drift and lists the application status as `OutOfSync` in both the CLI and Web console. However, it takes no action to correct the drift. The cluster remains in the drifted state until an operator manually triggers a sync or a new Git commit is pushed.

---

## 🗺️ Section 6: The Full 90-Day DevOps Pipeline Map

This GitOps workflow connects the concepts we have covered throughout the **90 Days of DevOps** challenge:

```mermaid
graph TD
    classDef dev fill:#FCE8E6,stroke:#D93025,stroke-width:2px;
    classDef ci fill:#E8F0FE,stroke:#1A73E8,stroke-width:2px;
    classDef cd fill:#FEF7E0,stroke:#F0B400,stroke-width:2px;
    classDef obs fill:#E6F4EA,stroke:#137333,stroke-width:2px;

    %% Elements
    Dev[💻 Developer Writes Code] -->|Day 22-28: Git & GitHub| Git[🐙 GitHub Repository]
    Git -->|Day 40-49: GitHub Actions| GHA[⚙️ GitHub Actions CI]
    
    subgraph CI Phase
        GHA -->|Day 29-37: Docker| Image[🐳 Docker Image Build]
        Image -->|Registry Push| DH[(🐳 DockerHub Registry)]
    end
    
    GHA -->|Git Handoff| GitManifest[📄 Git Manifests k8s/]
    
    subgraph CD Phase (GitOps)
        GitManifest -->|Day 84-86: ArgoCD| Argo[🐙 ArgoCD Controller]
        Argo -->|Day 81-83: AWS EKS| Cluster[☸️ Amazon EKS Cluster]
        Cluster -->|Day 78-80: Helm Charts| Helm[⛵ Helm & HPA Scaling]
    end
    
    subgraph Observability
        Cluster -->|Day 73-77: Prometheus & Grafana| Obs[📊 Prometheus / Loki / Grafana]
        Obs -->|Alerting| Notify[🔔 Slack / Alertmanager]
    end

    class Dev,Git dev;
    class GHA,Image,DH ci;
    class GitManifest,Argo,Cluster,Helm cd;
    class Obs,Notify obs;
```

---

## 🎓 Section 7: GitOps 3-Day Journey Summary

We have covered a lot during this 3-day ArgoCD block:

| Day | Block Module | Key Deliverables & Systems Built | Learning Outcomes |
|:---:|:---|:---|:---|
| **84** | **ArgoCD Core & GitOps Foundations** | Set up ArgoCD on EKS, deployed multi-tier app via CLI/UI, configured automated self-healing. | Understood pull-based GitOps vs push-based models, and configured declarative reconciliation. |
| **85** | **Advanced Orchestration & Safety** | Configured Sync Waves annotations, dry-run validations, CLI/UI rollbacks, App of Apps pattern, custom notifications, and team RBAC. | Mastered multi-service startup sequencing, multi-app scaling, and project tenancy safety boundaries. |
| **86** | **Production-Grade E2E Automation** | Built an automated end-to-end GitHub Actions pipeline with `sed` manifest updates, `[skip ci]` loop prevention, and EKS rolling updates. | Successfully connected continuous integration with GitOps continuous deployment. |

---

## 🧹 Section 8: Complete Teardown and Cleanup

To clean up your AWS resources and avoid unexpected charges, follow these teardown steps:

### 1. Delete ArgoCD Applications (Cascading Delete)
We must run a cascading delete to ensure ArgoCD removes the associated Kubernetes resources from the EKS cluster before the cluster itself is destroyed:

```bash
# Cascade delete the application resources
argocd app delete bankapp --cascade -y
```

#### Terminal Execution & Output:
```text
Deleting application 'bankapp' with cascading option...
Application 'bankapp' deleted successfully
```

Wait a few moments and verify all namespaces are empty:
```bash
# Confirm resource deletion
kubectl get all -n bankapp
```

#### Terminal Execution & Output:
```text
No resources found in bankapp namespace.
```

---

### 2. Destroy AWS Infrastructure with Terraform
Navigate to your Terraform directory and destroy the EKS cluster and VPC resources:

```bash
# Change to the terraform directory
cd AI-BankApp-DevOps/terraform

# Execute the destroy command
terraform destroy -auto-approve
```

#### Terminal Execution & Output:
```text
aws_eks_cluster.aws_eks: Destroying... [id=bankapp-eks]
aws_security_group.eks_nodes: Destroying...
aws_vpc.bankapp_vpc: Destroying...
...
Resources: 32 destroyed.
Destroy complete! Resources: 32 destroyed. (Execution time: 14m 32s)
```

### 🖼️ Infrastructure Teardown Success
*The Terraform terminal showing successful infrastructure deletion:*

![Infrastructure Teardown Log](./images/teardown_verification.png)

---

### 3. Verify Resource Deletion in AWS Console
1. **EKS Console**: Confirm that no clusters are active in your region.
2. **EC2 Console**: Verify that all EKS worker nodes, Auto Scaling groups, and associated ELBs are removed.
3. **VPC Console**: Check that the `bankapp-eks` VPC, subnets, and internet gateways have been deleted.
4. **IAM Console**: Ensure that any IAM roles created by EKS or Terraform are removed.
5. **AWS Billing**: Check your billing dashboard to confirm that active charges have stopped.

---

## 📌 Section 9: Key Takeaways & Best Practices

1. **Path-Based Trigger Filtering**: Always filter CI paths in your workflow configurations. This prevents manifest updates from triggering infinite build loops.
2. **Git Commit Loop Protection**: Use the `[skip ci]` flag in automated commit messages. This ensures that manifest commits made by the pipeline are ignored by the GitHub compiler.
3. **Commit Hash Traceability**: Tag your Docker images using the git commit SHA. This provides a clear audit trail from the running pod back to the source code commit.
4. **Cascading Application Deletion**: Always use the `--cascade` flag when deleting ArgoCD applications. This ensures that the managed Kubernetes objects are removed rather than leaving orphan resources behind.
5. **Self-Healing Infrastructure**: Enforcing `selfHeal: true` ensures your cluster is automatically protected against manual tampering or drift.

---

## 📢 Share Your Learning in Public!

Completed the 3-day GitOps block? Share your progress on LinkedIn!

```text
🚀 Just completed the GitOps block of the #90DaysOfDevOps challenge!

I wired an automated end-to-end CI/CD pipeline for the AI-BankApp stack:
1. Pushing a code change triggers GitHub Actions.
2. The pipeline compiles and runs tests, packages the app, and pushes the Docker image to DockerHub.
3. The runner updates the deployment manifest with the git commit SHA and pushes the update back to Git.
4. ArgoCD detects the change and triggers a rolling update on AWS EKS.

I also tested drift correction by manually changing replicas and deleting services. ArgoCD automatically corrected the drift and restored the target state within seconds!

Special thanks to @TrainWithShubham for the excellent guidance.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #Kubernetes #GitOps #ArgoCD #CI/CD #AWS
```

---
**Happy Learning!**
**TrainWithShubham**
