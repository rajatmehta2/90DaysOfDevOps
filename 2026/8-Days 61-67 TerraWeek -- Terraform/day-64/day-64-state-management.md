# Day 64: Master the Map -- Terraform State Management, Remote Backends, and State Surgery

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![DevOps](https://img.shields.io/badge/DevOps-90%20Days-orange?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 64** of the 90 Days of DevOps challenge! Yesterday, we transformed our static configurations into dynamic, reusable, and environment-aware deployments using Input Variables, Outputs, Locals, and Data Sources.

Today, we dive into the **single most critical aspect** of HashiCorp Terraform: **State Management**. The `terraform.tfstate` file is the ultimate source of truth—the mapping engine between your declarative `.tf` configuration files and the real-world physical infrastructure running in the cloud. If you lose it, Terraform forgets your entire architecture. If it becomes corrupted, your next plan or apply could accidentally destroy production resources. 

Today we learn to manage state like enterprise professionals. We will shift from risky local state files to a highly secure, encrypted **Remote S3 Backend with DynamoDB State Locking**, execute **state imports**, perform advanced **state surgery** using CLI tools, and simulate and remediate **state drift**.

---

## 🏗️ State Architecture: Local State vs. Remote State Setup

Understanding the architectural difference between working locally and using a secured, collaborative remote backend:

```mermaid
graph TD
    %% Custom styles
    classDef dev fill:#E8F0FE,stroke:#1A73E8,stroke-width:2px;
    classDef tf fill:#FCE8E6,stroke:#D93025,stroke-width:2px;
    classDef aws fill:#E6F4EA,stroke:#137333,stroke-width:2px;
    classDef lock fill:#FEF7E0,stroke:#F0B400,stroke-width:2px;

    %% Nodes
    subgraph Devs [Developers / CI-CD Pipelines]
        Dev1["Developer A <br> (Terminal 1)"]
        Dev2["Developer B <br> (Terminal 2)"]
    end

    subgraph Operations [Terraform CLI Core Engine]
        TFC1["Terraform CLI <br> (Executes Apply)"]
        TFC2["Terraform CLI <br> (Executes Plan)"]
    end

    subgraph RemoteBackend [AWS Remote Backend Security Tier]
        S3["AWS S3 Bucket <br> (State Storage: dev/terraform.tfstate)"]
        DDB["DynamoDB Table <br> (State Locking: LockID)"]
    end

    %% Connections
    Dev1 -->|Runs Apply| TFC1
    Dev2 -->|Runs Plan| TFC2

    TFC1 -->|1. Acquire Lock (Acquired!)| DDB
    TFC2 -->|2. Check Lock (Blocked!)| DDB
    
    TFC1 -->|3. Read / Write State| S3
    
    %% Styling
    class Dev1,Dev2 dev;
    class TFC1,TFC2 tf;
    class S3 aws;
    class DDB lock;
```

---

## 🧠 Challenge Tasks & Deep Dive Solutions

### Task 1: Inspect Your Current State

Before migrating or editing our state, we need to understand what it contains. Using our AWS infrastructure from Day 63 (which includes a VPC, Subnet, Route Tables, Internet Gateway, Security Group, and EC2 instance), we explore the state commands.

#### 1. Execute State Exploration Commands

* **List all resources currently tracked in state:**
  ```bash
  terraform state list
  ```
  **Output:**
  ```text
  data.aws_ami.amazon_linux
  data.aws_availability_zones.available
  aws_instance.web_server
  aws_security_group.web_sg
  aws_subnet.public
  aws_vpc.main
  ```

* **Inspect every attribute of the managed EC2 compute instance:**
  ```bash
  terraform state show aws_instance.web_server
  ```
  **Output:**
  ```text
  # aws_instance.web_server:
  resource "aws_instance" "web_server" {
      ami                                  = "ami-0123456789abcdef0"
      arn                                  = "arn:aws:ec2:ap-south-1:123456789012:instance/i-0a1b2c3d4e5f67890"
      associate_public_ip_address          = true
      availability_zone                    = "ap-south-1a"
      cpu_core_count                       = 1
      cpu_threads_per_core                 = 1
      disable_api_termination              = false
      ebs_block_device                     = []
      get_password_data                    = false
      hibernation                          = false
      id                                   = "i-0a1b2c3d4e5f67890"
      instance_state                       = "running"
      instance_type                        = "t2.micro"
      ipv6_address_count                   = 0
      ipv6_addresses                       = []
      key_name                             = "my-aws-key"
      monitoring                           = false
      primary_network_interface_id         = "eni-0a1b2c3d4e5f67890"
      private_dns                          = "ip-10-0-1-50.ap-south-1.compute.internal"
      private_ip                           = "10.0.1.50"
      public_dns                           = "ec2-13-233-14-12.ap-south-1.compute.amazonaws.com"
      public_ip                            = "13.233.14.12"
      secondary_private_ips                = []
      security_groups                      = []
      source_dest_check                    = true
      subnet_id                            = "subnet-0a1b2c3d4e5f67890"
      tags                                 = {
          "Environment" = "dev"
          "ManagedBy"   = "Terraform"
          "Name"        = "terraweek-dev-server"
          "Project"     = "terraweek"
      }
      tags_all                             = {
          "Environment" = "dev"
          "ManagedBy"   = "Terraform"
          "Name"        = "terraweek-dev-server"
          "Project"     = "terraweek"
      }
      tenancy                              = "default"
      vpc_security_group_ids               = [
          "sg-0c1d2e3f4a5b6c7d8",
      ]

      capacity_reservation_specification {
          capacity_reservation_preference = "open"
      }

      credit_specification {
          cpu_credits = "standard"
      }

      enclave_options {
          enabled = false
      }

      metadata_options {
          http_endpoint               = "enabled"
          http_put_response_hop_limit = 1
          http_tokens                 = "optional"
          instance_metadata_tags      = "disabled"
      }

      root_block_device {
          delete_on_termination = true
          device_name           = "/dev/xvda"
          encrypted             = false
          iops                  = 100
          tags                  = {}
          throughput            = 0
          volume_id             = "vol-0a1b2c3d4e5f67890"
          volume_size           = 8
          volume_type           = "gp2"
      }
  }
  ```

#### 2. Essential State Questions Answered

> [!NOTE]
> **Q1: How many resources does Terraform track in your state?**
> **A:** Looking at the execution of `terraform state list`, Terraform tracks **4 managed resources** (`aws_instance.web_server`, `aws_security_group.web_sg`, `aws_subnet.public`, `aws_vpc.main`) and handles metadata cache for **2 data source queries** (`aws_ami` and `aws_availability_zones`).

> [!IMPORTANT]
> **Q2: What attributes does the state store for an EC2 instance?**
> **A:** State stores the comprehensive cloud resource metadata populated by the AWS API during provisioning—far beyond what was defined in our HCL code. This includes the unique **Instance ID (`id`)**, **ARN**, **public and private IPs**, hardware structure (**CPU cores**, **threads**), network settings (**ENI associations**, **security groups**), disk properties (**volume ID**, **throughput**, **mount paths**), and IMDSv2 metadata properties (**http_tokens**, **hop limit**).

> [!TIP]
> **Q3: Open `terraform.tfstate` in an editor and find the `serial` number. What does it represent?**
> **A:** The `serial` number is a monotonically increasing integer (e.g. `"serial": 12`) that represents the **logical version** of the state file. Every time a change is applied to the infrastructure that modifies state, the serial increments by `1`. If Terraform runs concurrently, the backend compares serial numbers; if a CLI command tries to commit an older serial than what exists in the backend, the write is blocked. This acts as a primary version-control safety rail.

---

### Task 2: Set Up S3 Remote Backend

Local state storage represents a severe vulnerability. If a local drive fails, a folder is deleted, or two engineers run simultaneous plans, the local state is lost or corrupted. We migrate our state files to an enterprise-grade backend: **Amazon S3** (for secure, versioned, encrypted storage) and **Amazon DynamoDB** (for state locking).

#### 1. Provision Backend Infrastructure via AWS CLI

First, we create the remote S3 state storage bucket and a DynamoDB table for concurrent lock keys.

```bash
# 1. Create S3 bucket in AP-South-1 (Mumbai) region
aws s3api create-bucket \
  --bucket terraweek-state-rajat \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# 2. Enable versioning (crucial for state rollback recovery)
aws s3api put-bucket-versioning \
  --bucket terraweek-state-rajat \
  --versioning-configuration Status=Enabled

# 3. Create the DynamoDB table with HASH Key 'LockID' (Required schema by Terraform)
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

**AWS CLI Provisioning Outputs:**
```json
{
    "Location": "http://terraweek-state-rajat.s3.amazonaws.com/"
}
{
    "TableDescription": {
        "TableName": "terraweek-state-lock",
        "TableStatus": "CREATING",
        "KeySchema": [
            {
                "AttributeName": "LockID",
                "KeyType": "HASH"
            }
        ],
        "AttributeDefinitions": [
            {
                "AttributeName": "LockID",
                "AttributeType": "S"
            }
        ],
        "BillingModeSummary": {
            "BillingMode": "PAY_PER_REQUEST",
            "LastUpdateToPayPerRequestDateTime": "2026-06-02T21:45:00Z"
        }
    }
}
```

#### 2. Update the HCL Configuration Block

We declare our remote S3 backend inside our Terraform configuration (e.g. `main.tf` or `backend.tf`):

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraweek-state-rajat"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

#### 3. Initialize and Migrate State

Once the backend block is added, we run initialization to trigger migration:

```bash
terraform init
```

**Migration Console Execution Log:**
```text
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  new "s3" backend. No existing state was found in the "s3" backend. Do you want to
  write this state to the new "s3" backend? This will overwrite any state already in
  the "s3" backend.
  
  Enter a value: yes

Successfully configured the backend "s3"! Terraform will automatically
use this backend from now on. You may now begin working with the AWS S3 backend.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v5.0.0...
- Installed hashicorp/aws v5.0.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

#### 4. Post-Migration Verification

1. **Verify S3 Object Storage:**
   ```bash
   aws s3 ls s3://terraweek-state-rajat/dev/
   ```
   *Console returns `terraform.tfstate` under the `dev/` prefix.*
2. **Verify Local State Emptiness:**
   Our local directory `terraform.tfstate` is now safely removed or empty.
3. **Run Plan Consistency Check:**
   ```bash
   terraform plan
   ```
   *Output returns: `No changes. Your infrastructure matches the configuration.` confirming migration was completed cleanly without modifying active resources.*

---

### Task 3: Test State Locking

State locking is a fundamental requirement in team environments. It prevents multiple developers or CI/CD pipelines from executing commands concurrently and corrupting the state file.

#### 1. Simulate Simultaneous Executions

* **Terminal 1 (Action):** Run `terraform apply` to block state.
  ```bash
  terraform apply
  ```
  *(Terminal 1 pauses at the standard interactive confirmation prompt: `Do you want to perform these actions?`)*

* **Terminal 2 (Concurrent Query):** While Terminal 1 is still open, run:
  ```bash
  terraform plan
  ```

#### 2. The Lock Error Output

Terminal 2 halts immediately and throws the following lock restriction:

```text
$ terraform plan
╷
│ Error: Error acquiring the state lock
│ 
│ Error message: ConditionalCheckFailedException: The item already exists
│ Lock Info:
│   ID:        49db4304-4b53-488f-7988-7ee8cb9527fe
│   Path:      terraweek-state-rajat/dev/terraform.tfstate
│   Operation: Apply
│   Who:       rajat@workspace.local
│   Version:   1.5.0
│   Created:   2026-06-02 16:15:30.123456 +0000 UTC
│   Info:      
│ 
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can override this check with the "-lock=false"
│ flag, but this is not recommended.
╵
```

> [!CAUTION]
> **Why is State Locking critical?**
> Without locking, if two engineers apply code changes at the same time, their Terraform CLI engines will write conflicting configurations to the same remote state file. The second apply will overwrite changes from the first apply, causing resource state corruption, resource orphanages in the cloud, and untracked changes. DynamoDB solves this by acquiring a lock item matching the LockID before any operation begins.

#### 3. Advanced Recovery: Force Unlocking

If an engineer's terminal crashes or a CI/CD runner is forcibly killed while holding a lock, the lock will become stale, blocking all future runs. To recover, we run:

```bash
terraform force-unlock 49db4304-4b53-488f-7988-7ee8cb9527fe
```

*Warning: Only run this command when you have verified that the engineer/process listed under `Who` in the error message is no longer executing their task.*

---

### Task 4: Import an Existing Resource

In real-world projects, you will often find resources that were created manually via the AWS Console or command line. We need to bring these existing resources under Terraform management without destroying or recreated them.

#### 1. Manually Create the Target Resource (AWS Console / CLI)

We manually create a test S3 bucket outside of Terraform:

```bash
aws s3api create-bucket \
  --bucket terraweek-import-test-rajat \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

#### 2. Define the HCL Resource Block

In our Terraform configuration file, we declare a matching resource block (the resource name must match our target, but we start with an empty body to let import discover attributes):

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-rajat"
}
```

#### 3. Run the Import Command

We tie the AWS real-world resource ID to our HCL resource name using `terraform import`:

```bash
terraform import aws_s3_bucket.imported terraweek-import-test-rajat
```

**Import Console Logs:**
```text
aws_s3_bucket.imported: Importing from ID "terraweek-import-test-rajat"...
aws_s3_bucket.imported: Import prepared!
  Prepared aws_s3_bucket for import
aws_s3_bucket.imported: Refreshing state... [id=terraweek-import-test-rajat]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

#### 4. Plan Reconciliation

We run `terraform plan` to verify that our configuration matches real-world attributes:

```bash
terraform plan
```
If we see any changes (e.g., missing tags or encryption settings that exist on the bucket), we update our HCL code block. Once `No changes. Your infrastructure matches the configuration` is printed, our code and real state are in perfect synchronization.

#### 5. Difference: `terraform import` vs. Creation from Scratch

| Feature | Creating from Scratch (`terraform apply`) | Importing Resource (`terraform import`) |
| :--- | :--- | :--- |
| **Origin** | Resource does not exist; HCL configuration defines the design first. | Resource already exists in AWS; created manually or via external scripts. |
| **API Action** | Calls cloud `Create` APIs to provision physical resources. | Calls cloud `Read` APIs to populate the `.tfstate` file with existing properties. |
| **HCL Code** | HCL block is written, then applied. | HCL placeholder is written, then imported, then updated to match reality. |

---

### Task 5: State Surgery -- mv and rm

Sometimes we need to refactor our code, rename resources to follow company guidelines, or stop tracking a resource without deleting it from our cloud provider. We use `state mv` and `state rm`.

#### 1. Renaming a Resource in State (`state mv`)

We want to rename our imported resource block from `aws_s3_bucket.imported` to `aws_s3_bucket.logs_bucket` without deleting and recreating it in AWS:

```bash
# 1. Rename the resource reference inside our Terraform state file
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```
**Output:**
```text
Move "aws_s3_bucket.imported" to "aws_s3_bucket.logs_bucket"
Successfully moved 1 object(s).
```

*Crucial Step: We immediately update our HCL configuration code in `main.tf` to match the new resource identifier:*
```hcl
# Updated resource block name
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "terraweek-import-test-rajat"
}
```

We verify the change by running a plan:
```bash
terraform plan
```
*Plan returns `No changes`—proving that the rename was executed completely within the state mapping without affecting our cloud resources.*

#### 2. Removing a Resource from State without Destroying (`state rm`)

We want to hand off ownership of the S3 bucket to another team or another Terraform configuration. We need to stop tracking the resource in our current state file, without destroying it in AWS:

```bash
terraform state rm aws_s3_bucket.logs_bucket
```
**Output:**
```text
Removed aws_s3_bucket.logs_bucket
Successfully removed 1 resource(s).
```

*Verification:*
We run `terraform plan` now:
```bash
terraform plan
```
*Terraform plan will show a creation plan to add `aws_s3_bucket.logs_bucket` from scratch. This proves that Terraform no longer tracks the bucket in its state mapping, but checking the AWS console shows that the bucket still exists and is completely safe in AWS.*

#### 3. Re-Importing the Resource

We bring it back under management to restore our configuration:
```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-rajat
```

---

### Task 6: Simulate and Fix State Drift

State drift occurs when changes are made to active cloud infrastructure outside of Terraform (e.g. manual changes via the AWS Console, AWS CLI commands, or scripts). This leads to a mismatch between the desired state configured in our HCL and the actual state of our resources.

#### 1. Simulate Drift in the AWS Console
1. Log into the AWS Console.
2. Navigate to EC2 and locate our `terraweek-dev-server`.
3. Manually modify its **Tags**: Change the tag key `Name` from `"terraweek-dev-server"` to `"ManuallyChanged"`.
4. Manually modify another setting, such as removing or adding a security group.

#### 2. Detect Drift using Terraform Plan

Back in the terminal, we run a plan to check for inconsistencies:

```bash
terraform plan
```

**Drift Detection Output:**
```text
aws_instance.web_server: Refreshing state... [id=i-0a1b2c3d4e5f67890]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web_server will be updated in-place
  ~ resource "aws_instance" "web_server" {
        id                                   = "i-0a1b2c3d4e5f67890"
      ~ tags                                 = {
          ~ "Name"        = "ManuallyChanged" -> "terraweek-dev-server"
            "Environment" = "dev"
            "ManagedBy"   = "Terraform"
            "Project"     = "terraweek"
        }
      ~ tags_all                             = {
          ~ "Name"        = "ManuallyChanged" -> "terraweek-dev-server"
            # (3 unchanged elements remain)
        }
        # (35 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

#### 3. Resolving the Drift

We have two options depending on our architectural needs:

* **Option A: Reconcile and Enforce Configuration (Restore Reality)**
  If the manual change was unauthorized, we run `terraform apply`. Terraform will overwrite the manual changes and restore the tags to `"terraweek-dev-server"`.
* **Option B: Accept Drift into Code (Accept Reality)**
  If the manual change was correct, we update our HCL configuration code in `main.tf` to match the change:
  ```hcl
  tags = merge(local.common_tags, {
    Name = "ManuallyChanged"
  })
  ```
  Running a plan now will show `No changes`, incorporating the drift into our code base.

For this lab, we execute **Option A** to restore our baseline:
```bash
terraform apply -auto-approve
```
*Verification Plan:* Running `terraform plan` again returns `No changes. Your infrastructure matches the configuration.` Drift is resolved!

---

## 🛠️ The State Management Toolkit

A summary cheat sheet of our state command toolkit:

| Command | Action Type | When to Use | Risk Level |
| :--- | :--- | :--- | :--- |
| `terraform show` | **Read-Only** | Inspecting the full state file attributes in human-readable formatting. | **Safe** |
| `terraform state list` | **Read-Only** | Listing resource addresses tracked in the state file. | **Safe** |
| `terraform state show <addr>` | **Read-Only** | Viewing the complete metadata profile of a specific resource address. | **Safe** |
| `terraform refresh` | **Read-Write** | Updating the state file with real-world infrastructure metrics. | **Safe** |
| `terraform import <addr> <id>`| **Write-Only** | Bringing pre-existing cloud resources under Terraform tracking. | **Medium** |
| `terraform state mv <old> <new>`| **State Mod** | Renaming resources or refactoring module blocks without recreating cloud components. | **High** |
| `terraform state rm <addr>` | **State Mod** | Removing a resource from state tracking without deleting it from AWS. | **High** |
| `terraform force-unlock <id>` | **Lock Override**| Removing stale state lock records caused by process crashes. | **High** |

---

## 📸 Lab Visual Validations

To verify the successful completion of these challenges, review the visual logs below:

### 1. Migrated S3 Backend Verification
Confirming that our local state has migrated successfully and `terraform.tfstate` is stored in our encrypted AWS S3 remote bucket.

![State in S3 Bucket](./s3_state_bucket.png)

### 2. State Lock Collision Prevention
Confirming that concurrent runs are blocked by state locking, showing the Lock ID and blocking error message from our DynamoDB table.

![Lock Error in CLI](./lock_error.png)

### 3. Terraform Resource Import Execution
Logs showing the successful execution of `terraform import`, bringing our manually created S3 bucket under Terraform control.

![Import Success](./import_success.png)

### 4. Drift Analysis Planning
Plan output showing the successful detection of manual changes made in the AWS Console, preparing to restore our configuration baseline.

![State Drift Plan](./state_drift_plan.png)

---

## 💡 Pro DevOps Tips & Best Practices

1. **Enable S3 Bucket Versioning:** S3 bucket versioning is essential for remote backends. If a state surgery goes wrong or the state becomes corrupted, versioning lets you easily roll back to a previous state file version.
2. **Restrict Console Access:** The best way to prevent drift is to enforce **Read-Only** access in the AWS Console for production environments. All changes should be made using HCL configurations through automated CI/CD pipelines.
3. **Automate Drift Detection:** Configure daily scheduled pipelines running `terraform plan -detailed-exitcode` in your CI/CD setup. If drift is detected (exit code 2), trigger alerts (e.g. via Slack or email) to notify the engineering team.
4. **Never Store Secrets in HCL Plaintext:** S3 remote backends should always have the `encrypt = true` flag enabled to protect sensitive metadata (like passwords or private keys) that may reside inside the state file.

---

## 📝 Reflection & Key Lessons

* **State is the Core:** Master state management is the foundation of working with Terraform in production. The state file must be protected, versioned, and locked.
* **Collaboration Ready:** Shifting from local state files to S3 and DynamoDB enables team collaboration, ensuring that our development workflows are secure and concurrent-safe.
* **Surgery is High-Risk:** While commands like `state mv` and `state rm` are powerful refactoring tools, they modify the state file directly. Always back up your state file before performing state surgery.

---

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*