# Day 81: Introduction to Amazon EKS with Terraform

[![AWS EKS](https://img.shields.io/badge/Amazon--EKS-v1.35-blue?style=for-the-badge&logo=amazoneks&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/Terraform-v1.x-purple?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day--81-red?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 81** of the **90 Days of DevOps Journey**! 🚀

Having mastered local Kubernetes deployments using Kind and dynamic templating with Helm, we are now ready to scale our workload to a production-grade cloud environment. Local environments are excellent for learning, but a enterprise-ready deployment of our **AI-BankApp** demands a highly available managed control plane, autoscaling worker nodes, persistent block storage, and robust IAM integration.

Today, we transition to **Amazon Web Services (AWS)** using **Amazon Elastic Kubernetes Service (EKS)**. We will study the Infrastructure as Code (IaC) configuration in the AI-BankApp repository (branch `feat/gitops`), provision a production-grade EKS cluster across multiple Availability Zones using Terraform, configure Kubernetes tools, connect to the cluster, manually deploy our banking application to validate networking and EBS persistent volumes, and perform a detailed running cost analysis.

---

## 📖 Table of Contents
1. [EKS Architecture & Core Components](#-eks-architecture--core-components)
2. [EKS Architecture Diagram](#-eks-architecture-diagram)
3. [Terraform Configuration Breakdown](#-terraform-configuration-breakdown)
4. [EKS Cluster Provisioning Guide](#-eks-cluster-provisioning-guide)
5. [Connecting to EKS & Verification](#-connecting-to-eks--verification)
6. [Manual Application Deployment & Validation](#-manual-application-deployment--validation)
7. [ArgoCD Dashboard Integration](#-argocd-dashboard-integration)
8. [Financial Assessment: EKS Cost Breakdown](#-financial-assessment-eks-cost-breakdown)
9. [Resource Cleanup Strategy](#-resource-cleanup-strategy)

---

## 🏗️ EKS Architecture & Core Components

Amazon EKS is a managed Kubernetes service that simplifies running Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes.

### 🧠 1. Control Plane vs. Data Plane
*   **AWS-Managed Control Plane**: AWS manages the Kubernetes master nodes, including the API Server, `etcd` database, Scheduler, and Controller Manager. The control plane is deployed across three Availability Zones (AZs) for high availability, backed by AWS SLAs, and automatically patched/upgraded.
*   **Customer-Managed Data Plane**: The worker nodes where Kubernetes pods run. EKS supports:
    *   **Managed Node Groups**: AWS automates the provisioning, scaling, OS updates, and draining of EC2 instances while they run inside your AWS account.
    *   **Self-Managed Nodes**: Custom EC2 configurations managed entirely by you.
    *   **Fargate Profiles**: Serverless container execution where AWS provisions and manages isolated micro-VMs per pod on demand.

### 🔌 2. Essential EKS Add-ons Used
To support the stateful and AI-driven **AI-BankApp**, EKS leverages six crucial cluster add-ons:
1.  **`coredns`**: Handles internal cluster service discovery and DNS resolution.
2.  **`kube-proxy`**: Manages network routing, iptables/IPVS rules, and load balancing for Kubernetes Services.
3.  **`vpc-cni`**: The AWS Virtual Private Cloud Container Network Interface. It assigns native VPC IP addresses directly to pods, making pod communication fast and directly routable within the VPC.
4.  **`eks-pod-identity-agent`**: The modern replacement for IRSA, allowing pods to assume IAM roles dynamically without complex OpenID Connect (OIDC) annotations.
5.  **`aws-ebs-csi-driver`**: The Elastic Block Store Container Storage Interface. This driver enables Kubernetes to dynamically provision AWS EBS volumes (gp3) for stateful pods (MySQL and Ollama storage).
6.  **`metrics-server`**: Collects resource metrics from Kubelets to power `kubectl top` commands and Horizontal Pod Autoscalers (HPA).

---

## 📊 EKS Architecture Diagram

Here is a visual representation of the networking and compute topology provisioned by our Terraform configuration:

```mermaid
graph TB
    subgraph AWS_Cloud ["☁️ Amazon Web Services (AWS)"]
        subgraph VPC ["🌐 Custom VPC (10.0.0.0/16)"]
            IGW["🚪 Internet Gateway"]
            
            subgraph Public_Subnets ["🟢 Public Subnets (10.0.1-3.0/24)"]
                ALB["⚖️ Application Load Balancer / Ingress"]
                NAT["🔄 NAT Gateway"]
            end
            
            subgraph Private_Subnets ["🔒 Private Subnets (10.0.4-6.0/24)"]
                subgraph Node_Group ["☸️ Managed Node Group (AL2023)"]
                    Node1["💻 t3.medium (AZ-A)"]
                    Node2["💻 t3.medium (AZ-B)"]
                    Node3["💻 t3.medium (AZ-C)"]
                end
            end
            
            subgraph Intra_Subnets ["🛡️ Intra Subnets (10.0.7-9.0/24)"]
                ENIs["🔌 EKS Control Plane ENIs"]
            end
        end

        subgraph AWS_Managed ["🛠️ AWS Managed Space"]
            ControlPlane["🧠 EKS Control Plane <br/> (API, etcd, Scheduler)"]
        end
        
        subgraph Addons ["🔌 EKS Add-ons"]
            cDNS["CoreDNS"]
            kProxy["Kube-Proxy"]
            vCNI["VPC-CNI"]
            ebsCSI["EBS CSI Driver"]
            podId["Pod Identity Agent"]
            mServer["Metrics Server"]
        end
    end

    %% Network Connections
    IGW <--> ALB
    ALB -->|Route Inbound Traffic| Node_Group
    Node_Group -->|Outbound Internet Updates| NAT
    NAT --> IGW
    
    %% EKS Control Plane Connections
    ControlPlane <--> ENIs
    ENIs <--> Node_Group
    
    %% Add-ons mounting
    ControlPlane -.-> Addons
    Node_Group -.-> ebsCSI
    
    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:1px,color:#fff;
    classDef vpc fill:#F4F6F7,stroke:#2E86C1,stroke-width:2px;
    classDef pub fill:#E8F8F5,stroke:#27AE60,stroke-width:2px;
    classDef priv fill:#FEF9E7,stroke:#D35400,stroke-width:2px;
    classDef intra fill:#F4ECF7,stroke:#8E44AD,stroke-width:2px;
    classDef ctrl fill:#232F3E,stroke:#111,stroke-width:2px,color:#fff;
    classDef addon fill:#EBF5FB,stroke:#3498DB,stroke-width:1px;

    class AWS_Cloud,AWS_Managed aws;
    class VPC vpc;
    class Public_Subnets pub;
    class Private_Subnets priv;
    class Intra_Subnets intra;
    class ControlPlane ctrl;
    class cDNS,kProxy,vCNI,ebsCSI,podId,mServer addon;
```

---

## 🗂️ Terraform Configuration Breakdown

The AI-BankApp repository (branch `feat/gitops`) structures its infrastructure using modular, reusable Terraform configurations under the `terraform/` directory.

### 📝 1. Variable Definitions: `variables.tf` & `terraform.tfvars`
Defines parameters for customization. This keeps our code highly reusable across staging and production accounts.
```hcl
variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "Target AWS Region"
}

variable "cluster_name" {
  type        = string
  default     = "bankapp-eks"
  description = "EKS Cluster Name"
}

variable "cluster_version" {
  type        = string
  default     = "1.35"
  description = "Kubernetes Version for EKS"
}

variable "node_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance size for worker nodes"
}

variable "node_desired_count" {
  type        = number
  default     = 3
}
```

### 📝 2. Networking Topology: `vpc.tf`
Uses the official AWS VPC module to provision a robust network topology:
*   **Public Subnets (3 AZs)**: Tagged with `kubernetes.io/role/elb = 1`. This instructs AWS to spawn Internet-facing Application Load Balancers (ALB) here.
*   **Private Subnets (3 AZs)**: Tagged with `kubernetes.io/role/internal-elb = 1` for hosting backend worker nodes securely away from public exposure.
*   **Intra Subnets (3 AZs)**: Dedicated subnets for the EKS control plane ENIs.
*   **NAT Gateway**: Provisioned in public subnets to translate traffic, letting private worker nodes safely fetch external resources (like the Ollama models and Docker images).

### 📝 3. Cluster Compute: `eks.tf`
Deploys EKS using the modern `terraform-aws-modules/eks/aws` module:
*   **OS/AMI**: Modern **Amazon Linux 2023 (AL2023)** for optimal security, container performance, and quick node boot times.
*   **Capacity**: Spawns a Managed Node Group containing 3x `t3.medium` instances (min 3, max 5) distributed across our 3 AZs.
*   **Add-ons**: Installs the 6 add-ons listed in the architecture section.
*   **IAM Integration**: Configures IAM Roles for Service Accounts (IRSA) mapping AWS policies dynamically to Kubernetes ServiceAccounts (e.g., granting the EBS CSI driver permissions to call EC2 volume APIs).

### 📝 4. GitOps Initialization: `argocd.tf`
Bootstrap ArgoCD directly into our newly minted cluster:
*   Uses the **Helm Provider** to deploy the `argo-cd` chart.
*   Sets the service type of `argocd-server` to `LoadBalancer` so the Web UI is immediately accessible.
*   Uses `depends_on = [module.eks]` to ensure EKS is fully running before Helm attempts installation.

---

## 🚀 EKS Cluster Provisioning Guide

Follow these steps to initialize, inspect, and provision the complete cloud infrastructure.

### Step 1: Pre-requisites Verification
Before interacting with AWS, ensure all necessary local tools are installed and updated:
```bash
terraform --version
aws --version
kubectl version --client
helm version
```

#### Terminal Output:
```text
Terraform v1.8.2
on darwin_arm64
aws-cli/2.15.30 Python/3.11.8 Darwin/23.4.0 exe/x86_64
Client Version: v1.35.0
Kustomize Version: v5.0.4-0.20230601165947-6ce0bb390e38
version.BuildInfo{Version:"v3.14.2", GitCommit:"c3d75031b084", GitTreeState:"clean", GoVersion:"go1.21.7"}
```

### Step 2: Configure AWS Credentials
Configure your terminal to authenticate with your AWS account:
```bash
aws configure
```
```text
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```

Verify your authentication context:
```bash
aws sts get-caller-identity
```
```json
{
    "UserId": "AIDASCIREQDYNJEXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/rajat-devops-admin"
}
```

### Step 3: Initialize Terraform
Navigate to the `terraform/` directory of the cloned repository and initialize the working directory to download providers and modules:
```bash
cd terraform/
terraform init
```

#### Simulated Terminal Output:
```text
Initializing the backend...
Initializing modules...
Downloading terraform-aws-modules/vpc/aws 5.5.2 for vpc...
Downloading terraform-aws-modules/eks/aws 20.8.5 for eks...

Initializing provider plugins...
- Finding hashicorp/aws versions >= 5.0.0...
- Finding hashicorp/helm versions >= 2.0.0...
- Installing hashicorp/aws v5.42.0...
- Installing hashicorp/helm v2.12.1...

Terraform has been successfully initialized! 🚀
```

### Step 4: Perform Dry-Run Plan Check
Generate and inspect the execution plan to see the 50+ AWS resources that will be provisioned:
```bash
terraform plan -out=tfplan
```

#### Simulated Terminal Output:
```text
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
  # module.vpc.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" { ... }
  # module.eks.aws_eks_cluster.this[0] will be created
  + resource "aws_eks_cluster" "this" { ... }
  # module.eks.aws_eks_node_group.this["primary"] will be created
  + resource "aws_eks_node_group" "this" { ... }

Plan: 52 to add, 0 to change, 0 to destroy.
```

### Step 5: Deploy Infrastructure (Apply)
Execute the plan. EKS control plane provisioning takes between 15-20 minutes:
```bash
terraform apply tfplan
```

#### Simulated Terminal Output:
```text
module.vpc.aws_vpc.this[0]: Creating...
module.vpc.aws_vpc.this[0]: Creation complete after 6s [ID: vpc-0123456789abcdef0]
module.eks.aws_eks_cluster.this[0]: Creating...
module.eks.aws_eks_cluster.this[0]: Still creating... (10m0s elapsed)
module.eks.aws_eks_cluster.this[0]: Creation complete after 12m45s [ID: bankapp-eks]
module.eks.aws_eks_node_group.this["primary"]: Creating...
module.eks.aws_eks_node_group.this["primary"]: Creation complete after 3m10s
helm_release.argocd: Creating...
helm_release.argocd: Creation complete after 1m15s

Apply complete! Resources: 52 added, 0 changed, 0 destroyed.

Outputs:
configure_kubectl = "aws eks update-kubeconfig --name bankapp-eks --region us-west-2"
argocd_loadbalancer = "a8efc1682823a07b7193f773950a7c41-123456789.us-west-2.elb.amazonaws.com"
```

---

## 🔌 Connecting to EKS & Verification

Once provisioning is complete, link your local `kubectl` to the new cloud cluster.

### Step 1: Update Local Kubeconfig
Run the command provided by the Terraform output:
```bash
aws eks update-kubeconfig --name bankapp-eks --region us-west-2
```
```text
Added new context arn:aws:eks:us-west-2:123456789012:cluster/bankapp-eks to /Users/ToucanRajat/.kube/config
```

### Step 2: Confirm Connection context
```bash
kubectl config current-context
kubectl cluster-info
```
```text
arn:aws:eks:us-west-2:123456789012:cluster/bankapp-eks

Kubernetes control plane is running at https://A8EFC1682823A07B7193F773950A7C41.gr7.us-west-2.eks.amazonaws.com
CoreDNS is running at https://A8EFC1682823A07B7193F773950A7C41.gr7.us-west-2.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Step 3: Verify Nodes & System Status

Check that all worker nodes have registered, spread across Availability Zones, and are reporting `Ready`:
```bash
kubectl get nodes -o wide
```

#### Terminal Output:
```text
NAME                                       STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP    OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-4-32.us-west-2.compute.internal    Ready    <none>   5m    v1.35.0   10.0.4.32     54.187.2.14    Amazon Linux 2023   6.1.72-96.166.amzn2023.x86_64   containerd://1.7.11
ip-10-0-5-188.us-west-2.compute.internal   Ready    <none>   5m    v1.35.0   10.0.5.188    44.225.10.98   Amazon Linux 2023   6.1.72-96.166.amzn2023.x86_64   containerd://1.7.11
ip-10-0-6-77.us-west-2.compute.internal    Ready    <none>   5m    v1.35.0   10.0.6.77     35.160.82.1    Amazon Linux 2023   6.1.72-96.166.amzn2023.x86_64   containerd://1.7.11
```

---

### 🖼️ Verification Screenshot Placeholders

Here is where the visual outputs of our EKS configurations should be captured:

#### 1. Cluster Worker Nodes Status (`kubectl get nodes`)
Place a screenshot showing your 3 EKS nodes in a healthy `Ready` state across AZs.
![EKS Cluster Nodes Status](./images/kubectl_get_nodes.png)

#### 2. System Pods & Add-ons (`kubectl get pods -n kube-system`)
Confirm that the control plane agents, CoreDNS, and AWS CNI / EBS CSI driver pods are running.
![EKS Kube-System Pods and Add-ons](./images/kube_system_pods.png)

---

## 🧪 Manual Application Deployment & Validation

Before delegating our pipeline synchronization entirely to ArgoCD (GitOps) in upcoming days, we perform a manual deployment of the **AI-BankApp** stack from the repository root to ensure the cluster's networking, persistent storage dynamic volume provisioning, and HPA systems are functional.

### Step 1: Deploy Manifests
Apply all manifests from the `k8s/` directory sequentially:
```bash
cd ../ # Back to repo root
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/ollama-deployment.yml
kubectl apply -f k8s/bankapp-deployment.yml
kubectl apply -f k8s/hpa.yml
```

### Step 2: Monitor Startup Sequence
Deploying stateful pods requires a sequential startup due to dependencies:
1.  **MySQL Database**: Starts first, dynamically claiming a 5Gi persistent block volume via the EBS CSI driver, initializing tables in ~30s.
2.  **Ollama AI Engine**: Starts and begins downloading the **TinyLlama** model inside its pod (~2-4 minutes).
3.  **AI-BankApp Frontend**: Init-containers poll the backend. Once MySQL and Ollama are healthy, the core Java application boots.

Check pod deployment progress:
```bash
kubectl get pods -n bankapp -w
```
```text
NAME                                 READY   STATUS            RESTARTS   AGE
mysql-deployment-55df9889-m8snx      1/1     Running           0          4m20s
ollama-deployment-7cb5f98cf-kdf12    1/1     Running           0          4m20s
bankapp-deployment-64d5cbf8f-z2l54   0/1     Init:0/1          0          3m30s
bankapp-deployment-64d5cbf8f-z2l54   0/1     PodInitializing   0          4m10s
bankapp-deployment-64d5cbf8f-z2l54   1/1     Running           0          4m35s
```

### Step 3: Validate EBS Persistent Storage Provisioning
EKS should dynamically provision physical AWS EBS block volumes through our `aws-ebs-csi-driver` add-on:
```bash
kubectl get pvc -n bankapp
kubectl get pv
```

#### Terminal Output:
```text
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pvc     Bound    pvc-12345678-abcd-ef01-2345-67890abcdef0   5Gi        RWO            gp3            5m
ollama-pvc    Bound    pvc-87654321-dcba-fe10-5432-0fedcba98765   10Gi       RWO            gp3            5m

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
pvc-12345678-abcd-ef01-2345-67890abcdef0   5Gi        RWO            Delete           Bound    bankapp/mysql-pvc     gp3                     5m
pvc-87654321-dcba-fe10-5432-0fedcba98765   10Gi       RWO            Delete           Bound    bankapp/ollama-pvc    gp3                     5m
```

---

#### 🖼️ Dynamic Volume Provisioning Screenshot
Capture your PVCs bound and mapped correctly to the storage controller:
![EKS Dynamic Storage PVC Volume Mounts](./images/kubectl_get_pvc.png)

---

### Step 4: Access the Frontend Locally
Since our frontend manifests aren't exposed via a public load balancer yet, we tunnel to the cluster locally:
```bash
kubectl port-forward svc/bankapp-service -n bankapp 8080:8080
```

#### Terminal Output:
```text
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```

Open your browser and navigate to `http://localhost:8080`. You should be greeted by the secure **AI-BankApp Portal**!
- Create a test account.
- Log in and test database writes.
- Engage with the **AI chatbot helper** powered by the Ollama instance running inside EKS!

---

#### 🖼️ Active Application Interface Screenshot
Place a screenshot of the running AI-BankApp front login screen or active chat interface dashboard:
![AI-BankApp Frontend Dashboard Running on EKS](./images/ai_bankapp_running.png)

---

### Step 5: Verify Horizontal Pod Autoscaler (HPA)
The metrics server add-on allows HPA to read real-time pod metrics:
```bash
kubectl get hpa -n bankapp
```
```text
NAME          REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
bankapp-hpa   Deployment/bankapp-deployment   12%/70%         2         5         2          10m
```

---

## 📥 ArgoCD Dashboard Integration

Our Terraform configuration automated the installation of ArgoCD into the namespace `argocd`. Let's verify and access it.

### Step 1: Retrieve UI Access URL
```bash
kubectl get svc -n argocd argocd-server
```
```text
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                                             PORT(S)                      AGE
argocd-server   LoadBalancer   172.20.144.12   a8efc1682823a07b7193f773950a7c41-123456789.us-west-2.elb.amazonaws.com   80:31256/TCP,443:32254/TCP   20m
```

### Step 2: Fetch Initial Admin Password
ArgoCD stores its auto-generated admin credential in a secret:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
```text
vG923tLzKz8NEXeJ
```

Navigate to `http://a8efc1682823a07b7193f773950a7c41-123456789.us-west-2.elb.amazonaws.com` (using the load balancer hostname retrieved in step 1), enter user `admin`, and the decrypted password to access the central GitOps control board.

---

## 📊 Financial Assessment: EKS Cost Breakdown

EKS is a powerful managed system, but running resources on public clouds incurs continuous costs. Below is the monthly and daily cost projection for hosting this lab on AWS (us-west-2):

| Resource Component | Billing Metrics / Metrics Mode | Cost (Hourly) | Projected Cost (Monthly) |
| :--- | :--- | :--- | :--- |
| **EKS Control Plane** | AWS Managed Management Fee | $0.10 / hr | ~$73.00 |
| **Worker Nodes (3x t3.medium)** | Compute Fee ($0.0416/hr per node) | $0.1248 / hr | ~$91.10 |
| **NAT Gateway** | Network translation outbound fee | $0.045 / hr | ~$32.85 |
| **AWS EBS Storage (15Gi gp3)** | Allocated Block storage rate | $0.002 / hr | ~$1.50 |
| **LoadBalancer (ArgoCD)** | Elastic Load Balancing provision fee | $0.025 / hr | ~$18.25 |
| **Outbound Data Transfer** | Network traffic charges | Variable | Variable |
| **Estimated Total** | **Standard Running Cost Rate** | **~$0.30 / hr** | **~$216.70 / month (~$7.20 / day)** |

### 💡 Why is the NAT Gateway surprisingly expensive?
Even if no traffic is actively flowing out, AWS charges a flat hourly base fee ($0.045/hr in US-West-2) for keeping the NAT Gateway provisioned in the public subnet. When combined with outbound data transfer fees (e.g. pods pulling large container images or downloading models), the costs can rise quickly. 
*   *Production Tip*: In enterprise setups, you can lower costs by deploying **VPC Endpoints (AWS PrivateLink)** to route internal traffic directly to AWS services (like ECR, S3, systems manager) without going through a NAT Gateway.

---

## 🧹 Resource Cleanup Strategy

To prevent unexpected billing charges on your AWS account, always clean up your environment when you are done.

### Step 1: Tear Down Manual Workloads
Always delete manual Kubernetes applications and dynamic volume claims first:
```bash
kubectl delete -f k8s/hpa.yml
kubectl delete -f k8s/bankapp-deployment.yml
kubectl delete -f k8s/ollama-deployment.yml
kubectl delete -f k8s/mysql-deployment.yml
kubectl delete -f k8s/service.yml
kubectl delete -f k8s/secrets.yml
kubectl delete -f k8s/configmap.yml
kubectl delete -f k8s/pvc.yml
kubectl delete -f k8s/pv.yml
kubectl delete -f k8s/namespace.yml
```

### Step 2: Destroy Terraform Infrastructure
Run the destroy command in the `terraform/` directory to tear down the EKS cluster, node groups, IAM roles, and the custom VPC:
```bash
cd terraform/
terraform destroy --auto-approve
```

#### Simulated Destroy Log:
```text
module.eks.aws_eks_node_group.this["primary"]: Destroying... [id=bankapp-eks:primary]
module.eks.aws_eks_node_group.this["primary"]: Destruction complete after 2m45s
module.eks.aws_eks_cluster.this[0]: Destroying... [id=bankapp-eks]
module.eks.aws_eks_cluster.this[0]: Destruction complete after 5m15s
module.vpc.aws_vpc.this[0]: Destroying... [id=vpc-0123456789abcdef0]
module.vpc.aws_vpc.this[0]: Destruction complete after 12s

Destroy complete! Resources: 52 destroyed. 🧹
```

---

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*