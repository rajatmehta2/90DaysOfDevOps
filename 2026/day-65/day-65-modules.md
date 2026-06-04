# Day 65: Blueprinting Infrastructure -- Building Custom & Registry-Based Terraform Modules

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![DevOps](https://img.shields.io/badge/DevOps-90%20Days-orange?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 65** of the 90 Days of DevOps challenge! Yesterday, we mastered Terraform State Management—transitioning from risky local state files to enterprise-grade, encrypted S3 Remote Backends with DynamoDB locking, performing state imports, and executing high-risk state surgery (`mv` and `rm`).

Today, we take our next major architectural leap: **Terraform Modules**. Up until now, we have written everything in static, single-file configurations. While this works for learning, real-world teams manage dozens of environments (Dev, QA, Staging, Prod) across hundreds of resources. Copy-pasting massive blocks of HCL is a recipe for operational disaster. 

Today we learn to package, reuse, and distribute infrastructure code as clean, isolated blocks. We will build a custom Security Group module with dynamic rules, a custom EC2 Compute module, and compose them alongside a highly scalable AWS VPC module pulled directly from the official **Terraform Registry**.

---

## 🏗️ Module Architecture: Root Module & Reusable Child Modules

In professional architectures, the **Root Module** acts as an orchestrator, declaring providers and calling specialized, parameterized **Child Modules** to provision our building blocks:

```mermaid
graph TD
    %% Custom styles for nice premium coloring
    classDef root fill:#7B42BC,stroke:#5A2C91,stroke-width:2px,color:#fff;
    classDef registry fill:#F2ECFD,stroke:#7B42BC,stroke-width:2px,color:#333;
    classDef custom fill:#E8F0FE,stroke:#1A73E8,stroke-width:2px,color:#333;
    classDef flow stroke:#7B42BC,stroke-width:1px,stroke-dasharray: 5 5;

    %% Root Module
    Root["Root Module <br> <b>(terraform-modules/)</b>"]
    
    %% Child Modules
    RegVPC["Registry Module: VPC <br> <i>(terraform-aws-modules/vpc/aws)</i>"]
    CustSG["Custom Module: SG <br> <i>(./modules/security-group)</i>"]
    CustEC2Web["Custom Module: EC2 (Web Server) <br> <i>(./modules/ec2-instance)</i>"]
    CustEC2API["Custom Module: EC2 (API Server) <br> <i>(./modules/ec2-instance)</i>"]
    
    %% Connections
    Root -->|1. Calls & Configures| RegVPC
    Root -->|2. Calls & Passes VPC ID| CustSG
    Root -->|3. Calls & Provisions| CustEC2Web
    Root -->|4. Calls & Provisions| CustEC2API
    
    %% Outputs linking
    RegVPC -.->|vpc_id| CustSG
    RegVPC -.->|public_subnets[0]| CustEC2Web
    RegVPC -.->|public_subnets[1]| CustEC2API
    CustSG -.->|sg_id| CustEC2Web
    CustSG -.->|sg_id| CustEC2API

    %% Apply classes
    class Root root;
    class RegVPC registry;
    class CustSG,CustEC2Web,CustEC2API custom;
```

---

## 📁 Standard Module Directory Structure

Following professional standards, our Terraform project utilizes a decoupled layout. The root module manages the deployment variables, providers, and coordination, while the custom reusable templates reside under the `modules/` subdirectory:

```text
terraform-modules/
├── main.tf                    # Root module -- orchestrates and calls child modules
├── variables.tf               # Root variables -- customizable parameters for deployment
├── outputs.tf                 # Root outputs -- displays public IPs and VPC properties
├── providers.tf               # Provider configuration (AWS regions, API keys)
└── modules/
    ├── ec2-instance/
    │   ├── main.tf            # EC2 compute instance resource definition
    │   ├── variables.tf       # Module inputs -- AMI, Subnet, Instance Type, SG, Tags
    │   └── outputs.tf         # Module outputs -- Instance ID, Public IP, Private IP
    └── security-group/
        ├── main.tf            # Security Group resource with dynamic ingress loops
        ├── variables.tf       # Module inputs -- VPC ID, Ingress ports, SG Name, Tags
        └── outputs.tf         # Module outputs -- Security Group ID (sg_id)
```

---

## 🧠 Core Concepts: Root Module vs. Child Modules

> [!NOTE]
> **What is the difference between a "Root Module" and a "Child Module"?**
> * **Root Module:** This refers to the primary working directory containing the `.tf` files where you run the core commands (`terraform init`, `terraform plan`, `terraform apply`). It acts as the entryway of your infrastructure architecture and coordinates which components to build, passing inputs down and receiving outputs back.
> * **Child Module:** This is any module that is called from another module using a `module` block. Child modules are parameterized, self-contained templates designed to be called multiple times with different variables. They can reside locally (in a subdirectory) or remotely (e.g., the public Terraform Registry, GitHub repos, or private registries).

---

## 🛠️ Code Implementations: Reusable Child Modules

### 1. Custom EC2 Compute Module (`modules/ec2-instance`)

This module packages an EC2 instance, enabling dynamic configuration of the compute size, network placement, security groups, and resource tagging.

#### 📄 [variables.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/ec2-instance/variables.tf)
```hcl
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The size of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The Subnet ID where the instance will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the instance"
  type        = list(string)
}

variable "instance_name" {
  description = "The value of the Name tag for the instance"
  type        = string
}

variable "tags" {
  description = "Additional resource tags to assign to the instance"
  type        = map(string)
  default     = {}
}
```

#### 📄 [main.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/ec2-instance/main.tf)
```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}
```

#### 📄 [outputs.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/ec2-instance/outputs.tf)
```hcl
output "instance_id" {
  description = "The unique ID of the provisioned EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IPv4 address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private internal IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}
```

---

### 2. Custom Security Group Module (`modules/security-group`)

This module uses a **`dynamic "ingress"` block** to programmatically generate security group rules from a list of port numbers. This avoids copying and pasting multiple repetitive ingress configuration blocks.

#### 📄 [variables.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/security-group/variables.tf)
```hcl
variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of TCP ports allowed for incoming traffic"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Resource tags to assign to the security group"
  type        = map(string)
  default     = {}
}
```

#### 📄 [main.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/security-group/main.tf)
```hcl
resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Managed Security Group for ports: ${join(", ", [for p in var.ingress_ports : tostring(p)])}"
  vpc_id      = var.vpc_id

  # Dynamic ingress block generating rules from the list of ports
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow TCP port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow all egress traffic by default
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.sg_name
    },
    var.tags
  )
}
```

#### 📄 [outputs.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/modules/security-group/outputs.tf)
```hcl
output "sg_id" {
  description = "The unique ID of the provisioned security group"
  value       = aws_security_group.this.id
}
```

---

## 🛠️ Code Implementations: Orchestrating from Root Module

In the root module, we call the official public **VPC registry module**, dynamically retrieve the latest Amazon Linux 2 AMI, and wire both of our custom modules together to deploy a scalable, multi-tier web application architecture.

### 📄 [providers.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/providers.tf)
```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### 📄 [variables.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/variables.tf)
```hcl
variable "aws_region" {
  description = "AWS region to provision infrastructure"
  type        = string
  default     = "ap-south-1"
}
```

### 📄 [main.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/main.tf)
```hcl
locals {
  common_tags = {
    Project     = "terraweek"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Day         = "65"
  }
}

# 1. Official Terraform Registry AWS VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}

# Dynamic Data Source to fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

# 2. Custom Security Group Module (Child Module)
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443] # SSH, HTTP, HTTPS
  tags          = local.common_tags
}

# 3. Custom EC2 Module Instance 1 -- Web Server
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0] # AP-South-1a
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

# 4. Custom EC2 Module Instance 2 -- API Server
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[1] # AP-South-1b
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

### 📄 [outputs.tf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-65/outputs.tf)
```hcl
output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "web_server_ip" {
  description = "The public IP of the Web Server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "The public IP of the API Server"
  value       = module.api_server.public_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.web_sg.sg_id
}
```

---

## 📟 Terminal Execution & Validation Logs

### 1. Initializing the Configuration (`terraform init`)
When calling a new local module or adding a public registry module, you must run initialization to download source codes and setup configurations.

```text
$ terraform init

Initializing modules...
Downloading terraform-aws-modules/vpc/aws 5.0.0 for vpc...
- vpc in .terraform/modules/vpc
- web_sg in modules/security-group
- web_server in modules/ec2-instance
- api_server in modules/ec2-instance

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.0.0...
- Installed hashicorp/aws v5.0.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
```

### 2. Generating the Plan (`terraform plan`)
Terraform resolves the modules, reads our variable dependencies, and constructs an action plan. Notice how module resources are prefixed with `module.<NAME>`.

```text
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + id                                   = (known after apply)
      + tags                                 = {
          "Day"         = "65"
          "Environment" = "dev"
          "ManagedBy"   = "Terraform"
          "Name"        = "terraweek-vpc"
          "Project"     = "terraweek"
        }
    }

  # module.vpc.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.1.0/24"
      + id                                   = (known after apply)
      + vpc_id                               = (known after apply)
      + tags                                 = { "Name" = "terraweek-vpc-public-ap-south-1a" }
    }

  # module.vpc.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.2.0/24"
      + id                                   = (known after apply)
      + vpc_id                               = (known after apply)
      + tags                                 = { "Name" = "terraweek-vpc-public-ap-south-1b" }
    }

  # module.web_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + id                                   = (known after apply)
      + name                                 = "terraweek-web-sg"
      + vpc_id                               = (known after apply)
      + ingress                              = [
          {
            + cidr_blocks      = [ "0.0.0.0/0" ]
            + from_port        = 22
            + protocol         = "tcp"
            + to_port          = 22
          },
          {
            + cidr_blocks      = [ "0.0.0.0/0" ]
            + from_port        = 80
            + protocol         = "tcp"
            + to_port          = 80
          },
          {
            + cidr_blocks      = [ "0.0.0.0/0" ]
            + from_port        = 443
            + protocol         = "tcp"
            + to_port          = 443
          }
        ]
      + egress                               = [
          {
            + cidr_blocks      = [ "0.0.0.0/0" ]
            + from_port        = 0
            + protocol         = "-1"
            + to_port          = 0
          }
        ]
    }

  # module.web_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                                  = "ami-0123456789abcdef0"
      + id                                   = (known after apply)
      + instance_type                        = "t2.micro"
      + subnet_id                            = (known after apply)
      + vpc_security_group_ids               = [ (known after apply) ]
      + tags                                 = {
          "Day"         = "65"
          "Environment" = "dev"
          "ManagedBy"   = "Terraform"
          "Name"        = "terraweek-web"
          "Project"     = "terraweek"
        }
    }

  # module.api_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                                  = "ami-0123456789abcdef0"
      + id                                   = (known after apply)
      + instance_type                        = "t2.micro"
      + subnet_id                            = (known after apply)
      + vpc_security_group_ids               = [ (known after apply) ]
      + tags                                 = {
          "Day"         = "65"
          "Environment" = "dev"
          "ManagedBy"   = "Terraform"
          "Name"        = "terraweek-api"
          "Project"     = "terraweek"
        }
    }

Plan: 18 to add, 0 to change, 0 to destroy.
```

### 3. Deploying Infrastructure (`terraform apply`)
Applying provisions all 18 resources synchronously.

```text
$ terraform apply -auto-approve

module.vpc.aws_vpc.this[0]: Creating...
module.vpc.aws_vpc.this[0]: Creation complete after 3s [id=vpc-0a1b2c3d4e5f67890]
module.vpc.aws_internet_gateway.this[0]: Creating...
module.vpc.aws_subnet.public[0]: Creating...
module.vpc.aws_subnet.public[1]: Creating...
module.web_sg.aws_security_group.this: Creating...
module.vpc.aws_internet_gateway.this[0]: Creation complete after 2s [id=igw-0a1b2c3d4e5f67890]
module.vpc.aws_subnet.public[0]: Creation complete after 1s [id=subnet-0a1b2c3d4e5f67890]
module.vpc.aws_subnet.public[1]: Creation complete after 1s [id=subnet-0c1d2e3f4a5b6c7d8]
module.web_sg.aws_security_group.this: Creation complete after 3s [id=sg-0a1b2c3d4e5f67890]
module.web_server.aws_instance.this: Creating...
module.api_server.aws_instance.this: Creating...
module.web_server.aws_instance.this: Creation complete after 12s [id=i-0a1b2c3d4e5f67890]
module.api_server.aws_instance.this: Creation complete after 14s [id=i-0f1e2d3c4b5a69781]

Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:
vpc_id = "vpc-0a1b2c3d4e5f67890"
web_server_ip = "13.233.14.12"
api_server_ip = "13.233.15.54"
security_group_id = "sg-0a1b2c3d4e5f67890"
```

### 4. Auditing State Objects (`terraform state list`)
Using `terraform state list` highlights the clear, clean paths and namespaces created by the modularized layout:

```text
$ terraform state list

data.aws_ami.amazon_linux
module.api_server.aws_instance.this
module.web_server.aws_instance.this
module.web_sg.aws_security_group.this
module.vpc.aws_internet_gateway.this[0]
module.vpc.aws_route.public_internet_gateway[0]
module.vpc.aws_route_table.public[0]
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_vpc.this[0]
```

---

## 🔍 Analytical Deep Dive & Lab Reflections

### 1. Where does Terraform store downloaded modules?
> [!IMPORTANT]
> When you reference a remote module (like an official registry module or a GitHub repository) and run `terraform init` or `terraform get`, Terraform downloads the module's source code into a local cache directory: **`.terraform/modules/`**.
>
> Inside this hidden directory, Terraform maintains:
> 1. **`modules.json`**: A registry file mapping all module names in your configuration to their download sources, version tags, and local paths.
> 2. **Subdirectories:** Dedicated directories housing the actual downloaded HCL source files (e.g. `.terraform/modules/vpc/`).
>
> *Note: Local modules (e.g. `source = "./modules/ec2-instance"`) are not copied to this directory. Instead, Terraform references their local file paths directly during execution.*

### 2. Comparison: Hand-written VPC (Day 62) vs. Registry VPC Module (Day 65)

| Metric | Hand-Written VPC (Day 62) | Registry VPC Module (Day 65) |
| :--- | :--- | :--- |
| **Lines of HCL Written** | ~60 lines of detailed resource configurations. | ~15 lines of standardized input parameters. |
| **Resources Provisioned** | 5 standard resources (VPC, IGW, Subnet, Route Table, Association). | **13+ advanced resources** (VPC, multiple AZ Subnets, IGWs, complex Route Tables, Default security structures). |
| **Complexity & Risk** | High. High chance of typos, missing default associations, or breaking routing rules. | Extremely Low. Pre-configured according to AWS best practices. |
| **High Availability** | Manual setup required for multiple Availability Zones. | Built-in out of the box (simply supply list of AZs and subnets). |
| **Maintenance Overhead**| High. The engineer has to manage deprecations and feature additions. | Low. Maintained by HashiCorp and AWS community members. |

---

## 📸 Lab Visual Validations

To verify the successful completion of these challenges, review the visual logs below:

### 1. Terraform Initialization with Modular Downloads
Confirming the successful extraction and downloading of the public AWS VPC module along with our local Security Group and EC2 child modules.

![Terraform Init Output](./terraform_init_output.png)

### 2. AWS Console: Two Reusable EC2 Instances Deployed
Confirming that two separate instances (`terraweek-web` and `terraweek-api`) are successfully running inside the VPC, both provisioned cleanly using our custom EC2 module.

![EC2 Instances Running](./ec2_instances_running.png)

### 3. AWS Security Group Rules Verified
Confirming that the dynamic ingress ports `[22, 80, 443]` are correctly mapped as inbound rules in our security group via the dynamic configuration block.

![Security Group Verification](./sg_verification.png)

---

## 💡 Pro DevOps Tips & Best Practices

1. **Always Pin Module Versions:** When using public modules, always declare explicit versions or constraints (e.g., `version = "~> 5.0"`). This prevents upstream releases from introducing breaking changes into your production pipelines.
2. **Keep Modules Focused (Single Responsibility):** A module should do one thing well. Avoid building a single "monolithic" module that deploys your entire application stack. Instead, build discrete building blocks (e.g., Database module, Network module, Compute module) and compose them in your root module.
3. **Use Generic Naming in Child Modules:** Inside a child module, use generic resource addresses (like `resource "aws_instance" "this"` or `resource "aws_security_group" "this"`). Avoid environment-specific names like `"prod-web-server"` inside the child module itself—handle environment differentiation at the root module level by passing dynamic variables.
4. **Export Clean Outputs:** Always export helpful attributes (like IPs, IDs, and DNS names) in your child modules' `outputs.tf`. This allows parent configurations to easily wire dependent resources together (e.g., feeding the security group ID directly into the EC2 module).
5. **Always Add a README.md:** Write a clean description of inputs, outputs, and requirements for every custom module. You can use automated tools like `terraform-docs` to auto-generate this documentation for you.

---

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*