# Day 61: Introduction to Terraform & Your First AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![DevOps](https://img.shields.io/badge/DevOps-90%20Days-orange?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 61** of the 90 Days of DevOps challenge! Today marks our transition from managing applications, containers, and container orchestrators to building and managing the cloud infrastructure underneath them. We are kicking off our **Infrastructure as Code (IaC)** journey using **Terraform**—the industry-standard open-source tool for defining, provisioning, and managing cloud services through human-readable, declarative configuration files.

By the end of today's challenge, we will have configured the AWS CLI, installed Terraform, defined AWS resources via configuration code, ran the full Terraform lifecycle, and studied how state tracking keeps our cloud infrastructure consistent and drift-free.

---

## 🏗️ Terraform Workflow & Lifecycle

The standard developer workflow for Terraform centers around three core phases: **Write (Code) ➔ Plan (Dry Run) ➔ Apply (Deploy)**. Below is an architectural overview of how these commands interact with your configuration, the Terraform State engine, and real AWS resources.

```mermaid
graph TD
    %% Define styles
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef process fill:#EBF3FC,stroke:#2B78E4,stroke-width:1px;
    classDef state fill:#FFF3CD,stroke:#D3A117,stroke-width:1px;
    classDef cloud fill:#FFE7E7,stroke:#D9381E,stroke-width:1px;
    
    %% Components
    Config["HCL Config Code (main.tf)"]
    Init["1. terraform init"]
    Provider[".terraform/ (AWS Plugin)"]
    Plan["2. terraform plan"]
    Apply["3. terraform apply"]
    StateFile[("terraform.tfstate (JSON Engine)")]
    AWSCloud["AWS Infrastructure (S3, EC2)"]
    Destroy["4. terraform destroy"]

    %% Flow
    Config --> Init
    Init -->|Downloads| Provider
    Provider --> Plan
    Plan -->|Compares HCL with| StateFile
    Plan -->|Generates Execution Plan| Apply
    Apply -->|Executes API Calls| AWSCloud
    Apply -->|Records Real State| StateFile
    Destroy -->|Removes Resources| AWSCloud
    Destroy -->|Clears State| StateFile

    class Init,Plan,Apply,Destroy process;
    class StateFile state;
    class AWSCloud cloud;
```

---

## 🧠 Challenge Tasks & Deep Dive Solutions

### Task 1: Understand Infrastructure as Code

#### 1. What is Infrastructure as Code (IaC)? Why does it matter in DevOps?
**Infrastructure as Code (IaC)** is the practice of managing, provisioning, and configuring infrastructure resources (e.g., virtual machines, virtual networks, firewalls, subnets, load balancers) using machine-readable configuration files rather than physically setting up servers or interactively clicking buttons inside a cloud provider's console. 

In DevOps, IaC is foundational. It closes the gap between software development and systems operations by allowing teams to treat cloud infrastructure just like application code. With IaC, configurations can be placed in version control (Git), reviewed via Pull Requests (PRs), integrated into CI/CD pipelines, and deployed using automated test runners.

#### 2. What problems does IaC solve compared to manual console creation?
* **Elimination of Configuration Drift:** Manual clicking inevitably leads to inconsistencies across Dev, QA, Staging, and Production environments. IaC acts as the single source of truth, ensuring environment parity.
* **Speed and Scalability:** Deploying a multi-tier AWS network structure (VPCs, subnets, route tables, security groups) manually can take hours and is prone to errors. With IaC, deploying that entire footprint in a new region takes seconds.
* **Auditability and Compliance:** Manual console changes leave poor audit trails. IaC logs every change in git histories, showing precisely *who* altered *what*, *when*, and *why*.
* **Reusability & Disaster Recovery:** Entire complex environments can be packaged into reusable modules. In the event of a catastrophic regional failure, environments can be spun up in an alternative region instantly.

#### 3. How is Terraform different from AWS CloudFormation, Ansible, and Pulumi?

| IaC Vector | Terraform | AWS CloudFormation | Ansible | Pulumi |
| :--- | :--- | :--- | :--- | :--- |
| **Language** | HCL (HashiCorp Configuration Language) | JSON / YAML | YAML | Real Programming Languages (Go, Python, TypeScript, Node.js) |
| **Cloud Support** | **Cloud-Agnostic** (AWS, Azure, GCP, K8s, Cloudflare, etc.) | **AWS-Specific** (Proprietary tool native to AWS ecosystem) | **Cloud-Agnostic** | **Cloud-Agnostic** |
| **Execution Paradigm** | **Declarative** (Define desired end-state; engine handles logic) | **Declarative** (Define desired end-state) | **Procedural/Hybrid** (Task-oriented steps run sequentially) | **Declarative** (Define desired end-state) |
| **State Tracking** | Dedicated state engine file (`terraform.tfstate`) | Managed automatically internally by AWS CloudFormation | Stateless (directly queries active target nodes) | Dedicated state file (managed by Pulumi Cloud or self-hosted) |
| **Primary Use-Case** | **Infrastructure Provisioning** (Spinning up hardware resources) | **Infrastructure Provisioning** (AWS resources exclusively) | **Configuration Management** (Configuring OS, installing packages inside servers) | **Infrastructure Provisioning** (Using familiar language constructs) |

#### 4. What does it mean that Terraform is "declarative" and "cloud-agnostic"?
* **Declarative:** Unlike imperative/procedural tools where you must write step-by-step scripts detailing *how* to perform operations (e.g., "create subnet, wait 10s, then create VM"), Terraform lets you declare the *what* (e.g., "I want a VPC and an EC2 instance"). Terraform automatically calculates resource dependency trees, builds an optimal execution order, and performs API transactions to match your requested state.
* **Cloud-Agnostic:** Terraform does not favor a single cloud provider. Using a pluggable "provider architecture", a single Terraform manifest can orchestrate resources on AWS, Azure, Google Cloud, Heroku, Datadog, and Kubernetes simultaneously.

---

### Task 2: Install Terraform and Configure AWS

#### 1. Installation Commands
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (Ubuntu/Debian)
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# Windows (via Chocolatey)
choco install terraform -y
```

#### 2. Verification
To verify the installation, run:
```bash
terraform -version
```

**Realistic Terminal Output:**
```text
Terraform v1.14.7
on darwin_arm64
```

#### 3. AWS CLI Installation & Configuration
Configure your local environment to access your AWS account:
```bash
# Verify AWS CLI is installed
aws --version
```
**Realistic Terminal Output:**
```text
aws-cli/2.15.30 Python/3.11.8 Darwin/23.4.0 exe/x86_64 prompt/off
```

Configure your credentials:
```bash
aws configure
```
**Interactive Terminal Prompt:**
```text
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-south-1
Default output format [None]: json
```

Verify your active credentials and access permissions:
```bash
aws sts get-caller-identity
```

**Realistic Terminal Output:**
```text
{
    "UserId": "AIDASAMPLESOMERANDOMID",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-devops-admin"
}
```

---

### Task 3: Your First Terraform Config -- Create an S3 Bucket

To begin, create an isolated directory to store our configurations:
```bash
mkdir terraform-basics && cd terraform-basics
```

#### 1. Define the Configuration (`main.tf`)
Create a file named `main.tf` with the following contents:

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraweek-rajat-2026-s3-bucket"

  tags = {
    Name        = "TerraWeek-Day1-S3"
    Environment = "Dev"
  }
}
```

#### 2. Run the Lifecycle Commands

##### Step A: Initialize Terraform (`terraform init`)
Initialize the project directory to read the providers and download necessary plugins.
```bash
terraform init
```

**Realistic Terminal Output:**
```text
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.50.0...
- Installed hashicorp/aws v5.50.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
re-run this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so.
```

> [!NOTE]  
> **What did `terraform init` download?**  
> It analyzed `main.tf`'s `required_providers` and downloaded the platform-specific compiled binary of the **AWS Provider** from the public HashiCorp Registry.  
> **What does the `.terraform/` directory contain?**  
> It contains the cached provider plugins (specifically under `.terraform/providers/registry.terraform.io/hashicorp/aws/...`), which acts as the translator between Terraform's custom standard HCL and the AWS REST API.

##### Step B: Generate the Plan (`terraform plan`)
Create a preview execution plan to observe what AWS API changes will be executed without actually modifying any live systems.
```bash
terraform plan
```

**Realistic Terminal Output:**
```text
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.my_bucket will be created
  + resource "aws_s3_bucket" "my_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "terraweek-rajat-2026-s3-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "Dev"
          + "Name"        = "TerraWeek-Day1-S3"
        }
      + tags_all                    = {
          + "Environment" = "Dev"
          + "Name"        = "TerraWeek-Day1-S3"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

##### Step C: Apply Configuration (`terraform apply`)
Execute the changes to provision the live S3 Bucket in ap-south-1.
```bash
terraform apply
```

**Realistic Terminal Output:**
```text
...
[Outputs same plan details as above]
...
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.my_bucket: Creating...
aws_s3_bucket.my_bucket: Still creating... [10s elapsed]
aws_s3_bucket.my_bucket: Creation complete after 12s [id=terraweek-rajat-2026-s3-bucket]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

### Task 4: Add an EC2 Instance

Now, modify `main.tf` to introduce a compute instance alongside our existing storage bucket.

#### 1. Updated Configuration (`main.tf`)
Append the `aws_instance` block to `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraweek-rajat-2026-s3-bucket"

  tags = {
    Name        = "TerraWeek-Day1-S3"
    Environment = "Dev"
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0f5ee92e2d63afc18" # Amazon Linux 2 in ap-south-1
  instance_type = "t2.micro"

  tags = {
    Name = "TerraWeek-Day1"
  }
}
```

#### 2. Run the Update Lifecycle

##### Plan Preview
Observe that Terraform intelligently determines that the S3 bucket already exists and plans to provision *only* the new EC2 compute instance.
```bash
terraform plan
```

**Realistic Terminal Output:**
```text
aws_s3_bucket.my_bucket: Refreshing state... [id=terraweek-rajat-2026-s3-bucket]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.my_instance will be created
  + resource "aws_instance" "my_instance" {
      + ami                                  = "ami-0f5ee92e2d63afc18"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + get_password_data                    = false
      + id                                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + key_name                             = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "TerraWeek-Day1"
        }
      + tags_all                             = {
          + "Name" = "TerraWeek-Day1"
        }
      + vpc_security_group_ids               = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

##### Apply Deployment
Apply the plan.
```bash
terraform apply --auto-approve
```

**Realistic Terminal Output:**
```text
aws_s3_bucket.my_bucket: Refreshing state... [id=terraweek-rajat-2026-s3-bucket]
aws_instance.my_instance: Creating...
aws_instance.my_instance: Still creating... [10s elapsed]
aws_instance.my_instance: Still creating... [20s elapsed]
aws_instance.my_instance: Creation complete after 28s [id=i-0a1b2c3d4e5f67890]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### 🛠️ Core Concept Validation
**How does Terraform know the S3 bucket already exists and only the EC2 instance needs to be created?**  
When we applied Task 3, Terraform compiled the real-world provisioning state into a JSON database file called `terraform.tfstate` in your local directory. During subsequent commands (like `terraform plan`), the first step Terraform runs is **"Refreshing state"**. It parses this local state tracking file and calls AWS API endpoints to check if resources mapped in state still exist and match the code. Seeing that the S3 bucket is active and unchanged, it decides it needs to make 0 adjustments to it, configuring a plan exclusively for the newly added `aws_instance` definition.

---

### Task 5: Understand the State File

#### 1. Deep Dive: Inside the JSON State Engine
The state database `terraform.tfstate` acts as the mapping registry between your written configuration declarations and physical cloud hardware identities. Let's inspect a realistic structured block from our `terraform.tfstate` file:

```json
{
  "version": 4,
  "terraform_version": "1.14.7",
  "serial": 3,
  "lineage": "a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "my_instance",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0f5ee92e2d63afc18",
            "arn": "arn:aws:ec2:ap-south-1:123456789012:instance/i-0a1b2c3d4e5f67890",
            "id": "i-0a1b2c3d4e5f67890",
            "instance_state": "running",
            "instance_type": "t2.micro",
            "private_ip": "172.31.24.89",
            "public_ip": "13.233.12.45",
            "tags": {
              "Name": "TerraWeek-Day1"
            }
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "my_bucket",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "arn": "arn:aws:s3:::terraweek-rajat-2026-s3-bucket",
            "bucket": "terraweek-rajat-2026-s3-bucket",
            "id": "terraweek-rajat-2026-s3-bucket",
            "region": "ap-south-1",
            "tags": {
              "Environment": "Dev",
              "Name": "TerraWeek-Day1-S3"
            }
          }
        }
      ]
    }
  ]
}
```

#### 2. Running State Commands

##### Command 1: `terraform show`
Retrieves a highly readable, clear view of all live resources tracked inside the state file.
```bash
terraform show
```
**Realistic Terminal Output:**
```text
# aws_instance.my_instance:
resource "aws_instance" "my_instance" {
    ami                                  = "ami-0f5ee92e2d63afc18"
    arn                                  = "arn:aws:ec2:ap-south-1:123456789012:instance/i-0a1b2c3d4e5f67890"
    id                                   = "i-0a1b2c3d4e5f67890"
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    private_ip                           = "172.31.24.89"
    public_ip                            = "13.233.12.45"
    tags                                 = {
        "Name" = "TerraWeek-Day1"
    }
}

# aws_s3_bucket.my_bucket:
resource "aws_s3_bucket" "my_bucket" {
    arn                         = "arn:aws:s3:::terraweek-rajat-2026-s3-bucket"
    bucket                      = "terraweek-rajat-2026-s3-bucket"
    id                          = "terraweek-rajat-2026-s3-bucket"
    region                      = "ap-south-1"
    tags                        = {
        "Environment" = "Dev"
        "Name"        = "TerraWeek-Day1-S3"
    }
}
```

##### Command 2: `terraform state list`
Lists all raw addresses of resources managed inside your active state environment.
```bash
terraform state list
```
**Realistic Terminal Output:**
```text
aws_instance.my_instance
aws_s3_bucket.my_bucket
```

##### Command 3: `terraform state show`
Queries detailed, low-level attribute metrics of a single resource matching the address.
```bash
terraform state show aws_instance.my_instance
```
**Realistic Terminal Output:**
```text
# aws_instance.my_instance:
resource "aws_instance" "my_instance" {
    ami                                  = "ami-0f5ee92e2d63afc18"
    arn                                  = "arn:aws:ec2:ap-south-1:123456789012:instance/i-0a1b2c3d4e5f67890"
    id                                   = "i-0a1b2c3d4e5f67890"
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    tags                                 = {
        "Name" = "TerraWeek-Day1"
    }
}
```

#### 3. State Architectural Questions

* **What information does the state file store about each resource?**  
  It stores:
  * Resource metadata: Types, naming keys, and provider definitions.
  * Dependency bindings: What components must spin up before others.
  * Real-world operational values generated after provisioning that aren't defined in the static `.tf` code, such as auto-assigned internal IPs, public elastic IPs, DNS endpoints, and ARNs.

* **Why should you never manually edit the state file?**  
  The state file is delicate, highly structured JSON. A single syntax error, manual character typo, or unmatched resource hash identifier will corrupt the file. This leaves the Terraform engine unable to parse your history, causing plans to crash, and leaving orphaned resources in the cloud that must be hunted down and removed manually.

* **Why should the state file not be committed to Git?**  
  1. **Security Vulnerability:** State files cache all values in **plaintext**. If you define a database password, access token, or certificate private key, it is written directly into `terraform.tfstate`. Committing this database exposes these secrets.
  2. **State Concurrency / Race Conditions:** In standard engineering teams, two developers running `terraform apply` concurrently would trigger race conditions and overwrite each other's changes, leading to conflicts.
  3. **Local State Desynchronization:** Complicated pipelines require state locking. For proper operations, state files must be hosted in secure, central remote backends (like AWS S3 with state locking via DynamoDB) and filtered out of source control using `.gitignore`.

---

### Task 6: Modify, Plan, and Destroy

#### 1. Modify EC2 Tag
Modify `main.tf` to update the name tag of the EC2 instance:
```hcl
# In main.tf:
resource "aws_instance" "my_instance" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraWeek-Modified" # Updated tag value
  }
}
```

#### 2. Generate Plan
Analyze the execution symbols of the dry run:
```bash
terraform plan
```

**Realistic Terminal Output:**
```text
aws_s3_bucket.my_bucket: Refreshing state... [id=terraweek-rajat-2026-s3-bucket]
aws_instance.my_instance: Refreshing state... [id=i-0a1b2c3d4e5f67890]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.my_instance will be updated in-place
  ~ resource "aws_instance" "my_instance" {
        id                                   = "i-0a1b2c3d4e5f67890"
      ~ tags                                 = {
          ~ "Name" = "TerraWeek-Day1" -> "TerraWeek-Modified"
        }
      ~ tags_all                             = {
          ~ "Name" = "TerraWeek-Day1" -> "TerraWeek-Modified"
        }
        # (29 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

#### 🕵️ Symbol Meaning Decoder

* **`+` (Create):** Terraform will provision a brand-new resource in the cloud.
* **`~` (Update in-place):** Terraform will modify the configurations of an *existing* resource without recreating it (e.g., updating a security group rule, or changing a tag name).
* **`-` (Destroy):** Terraform will delete the resource.
* **`-/+` or `+/-` (Recreate):** The requested change targets an attribute that is immutable on the cloud provider side (e.g., changing the AMI of an active EC2 instance, or modifying the subnet ID). The resource must be destroyed and recreated from scratch to apply the update.

#### 3. Apply the Tag Update
Execute the modification.
```bash
terraform apply --auto-approve
```

**Realistic Terminal Output:**
```text
aws_instance.my_instance: Modifying... [id=i-0a1b2c3d4e5f67890]
aws_instance.my_instance: Modifications complete after 2s [id=i-0a1b2c3d4e5f67890]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

#### 4. Clean Up & Resource Teardown
To avoid unwanted charges in our AWS account, we will cleanly destroy all resources provisioned by our codebase.
```bash
terraform destroy
```

**Realistic Terminal Output:**
```text
aws_s3_bucket.my_bucket: Refreshing state... [id=terraweek-rajat-2026-s3-bucket]
aws_instance.my_instance: Refreshing state... [id=i-0a1b2c3d4e5f67890]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.my_instance will be destroyed
  - resource "aws_instance" "my_instance" {
      - ami                                  = "ami-0f5ee92e2d63afc18" -> null
      - arn                                  = "arn:aws:ec2:ap-south-1:123456789012:instance/i-0a1b2c3d4e5f67890" -> null
      - instance_type                        = "t2.micro" -> null
      - tags                                 = {
          - "Name" = "TerraWeek-Modified"
        } -> null
    }

  # aws_s3_bucket.my_bucket will be destroyed
  - resource "aws_s3_bucket" "my_bucket" {
      - arn                         = "arn:aws:s3:::terraweek-rajat-2026-s3-bucket" -> null
      - bucket                      = "terraweek-rajat-2026-s3-bucket" -> null
      - tags                        = {
          - "Environment" = "Dev"
          - "Name"        = "TerraWeek-Day1-S3"
        } -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you want to perform these actions?
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.my_instance: Destroying... [id=i-0a1b2c3d4e5f67890]
aws_s3_bucket.my_bucket: Destroying... [id=terraweek-rajat-2026-s3-bucket]
aws_instance.my_instance: Still destroying... [10s elapsed]
aws_instance.my_instance: Still destroying... [20s elapsed]
aws_instance.my_instance: Destruction complete after 25s
aws_s3_bucket.my_bucket: Destruction complete after 2s

Destroy complete! Resources: 2 destroyed.
```

---

## 📸 Lab Visual Validations

To finalize today's challenge documentation, insert your visual proofs here. Place your screenshot image files inside the `day-61/` directory.

### 1. Terraform Deployment Execution Output
This screenshot displays the complete CLI success output of `terraform apply --auto-approve` executing the creation of both the S3 storage bucket and EC2 compute instance.

![Terraform Apply Output](./terraform_apply.png)

### 2. Live Provisioned Infrastructure in the AWS Console
This screenshot displays the successfully created S3 bucket and active EC2 instance dashboard under the Amazon Web Services Management Console.

![AWS Management Console Resources](./aws_console_resources.png)

---

## 💡 Pro DevOps Tips & Best Practices

1. **Auto-Formatting is Crucial:** Run `terraform fmt` prior to committing your files. It automatically formats HCL code indentation, alignment, and styling to keep configurations clean and standardized.
2. **Pre-Deployment Validation:** Run `terraform validate` in your CI pipeline. This validates files for logical and structural syntax errors without initiating provider cloud connections.
3. **Establish a Resilient `.gitignore`:** Keep local state files, cache dirs, and backup logs out of version control. Add the following config to your project's `.gitignore` file:
   ```text
   # Local .terraform directory containing cached provider binaries
   .terraform/
   
   # Local JSON state databases and automated state back-ups
   *.tfstate
   *.tfstate.backup
   
   # Sensitive user inputs containing passwords or local configuration profiles
   *.tfvars
   *.tfvars.json
   ```
4. **Transition to Remote State Locking:** For production teams, configure a backend block using AWS S3 (for storage) combined with Amazon DynamoDB (for locking states) to prevent race conditions during updates.

---

## 📝 Reflection & Key Lessons

* **State is King:** Terraform is only as smart as its state file. It is the core source of truth. Protecting state with back-ups and encryption is critical.
* **HCL Simplicity:** The HashiCorp Configuration Language is incredibly readable and much cleaner than CloudFormation's raw JSON/YAML templates.
* **Declarative Paradigm Shift:** Coming from imperative Bash scripts, declaring the end-state and letting Terraform figure out the dependency graph feels like magic.

---

## 📢 Share Your Journey!

Ready to share your IaC milestone with the community? Copy and paste this post to LinkedIn:

```text
🚀 Day 61 of my #90DaysOfDevOps challenge is complete! I'm officially starting my Infrastructure as Code (IaC) journey! 🛠️☁️

Today, I took my first steps with HashiCorp Terraform:
🔹 Installed Terraform and configured the AWS CLI.
🔹 Created a fully declarative main.tf configuration containing an Amazon S3 Bucket and EC2 instance.
🔹 Explored the core Terraform lifecycle: init, plan, apply, and destroy.
🔹 Deep-dived into the terraform.tfstate engine to understand state mapping and prevent drift.

Provisioning and teardown of complex cloud networks in seconds using code is a game changer! Excited to dive into variables and multi-environment templates next.

#90DaysOfDevOps #TerraWeek #IaC #HashiCorp #Terraform #AWS #CloudComputing #DevOps
```

---

*Keep up the high energy! See you on Day 62!*
**TrainWithShubham**
