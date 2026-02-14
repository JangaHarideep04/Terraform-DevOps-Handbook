# Terraform Learning Guide - Complete Documentation

A comprehensive guide to Infrastructure as Code (IaC) using Terraform, covering all concepts, commands, best practices, and practical examples.

---

## Table of Contents

1. [Introduction to Infrastructure as Code](#introduction-to-infrastructure-as-code)
2. [Types of IaC Tools](#types-of-iac-tools)
3. [Terraform Overview](#terraform-overview)
4. [Core Terraform Commands](#core-terraform-commands)
5. [Terraform Architecture](#terraform-architecture)
6. [Meta-Arguments](#meta-arguments)
7. [Advanced Features](#advanced-features)
8. [State Management](#state-management)
9. [Variables and Configuration](#variables-and-configuration)
10. [Workspaces](#workspaces)
11. [Modules](#modules)
12. [Provisioning](#provisioning)
13. [Debugging](#debugging)
14. [Project Structure](#project-structure)

---

## Introduction to Infrastructure as Code

**Infrastructure as Code (IaC)** is the practice of managing and provisioning computing infrastructure through machine-readable definition files rather than physical hardware or interactive configuration tools.

### Benefits of IaC:
- **Version Control**: Track infrastructure changes over time
- **Reproducibility**: Consistently recreate environments
- **Automation**: Reduce manual errors and save time
- **Scalability**: Manage large infrastructures efficiently
- **Collaboration**: Team members can review and approve changes

---

## Types of IaC Tools

There are three main categories of IaC tools, each serving different purposes:

### 1. Configuration Management Tools

These tools focus on managing software configuration and packages on existing servers.

#### Ansible
- **Idempotent**: Running the same playbook multiple times won't create duplicate resources
- **Agent-less**: Requires only SSH access and Python on target machines (no agent installation needed)
- **Primary Use**: Installing packages, updating configurations on existing infrastructure
- **Example**: Installing httpd service across multiple worker nodes from a control node

**Key Characteristic**: Idempotence means if a resource already exists, Ansible won't recreate it. This differs from Terraform which is typically used for provisioning.

#### Puppet & Chef
- **Agent-based**: Requires agent installation on all managed machines
- **Centralized Management**: Agents communicate with central server
- **Primary Use**: Configuration management in large-scale environments
- **Comparison**: More complex than Ansible due to agent requirement

**Note**: Ansible is preferred over Puppet/Chef due to its agent-less architecture, reducing deployment complexity.

---

### 2. Server Templating Tools

These tools create pre-configured machine images that are **immutable** (cannot be changed after creation).

#### Characteristics:
- **Pre-installed Software**: AMIs, Docker images come with software pre-installed
- **Immutable Infrastructure**: Once created, they cannot be modified
- **Update Process**: Must create new images instead of modifying existing ones
- **Efficiency**: Faster deployment since all software is pre-configured

#### Examples:
- **Docker**: Container images with applications
- **Packer**: Tool to create custom AMIs, Docker images
- **Vagrant**: Lightweight VM provisioning for development

**Use Case**: When you need fast, consistent server deployments with predefined configurations.

---

### 3. Provisioning Tools

These tools deploy **mutable infrastructure** - creating and managing cloud resources that can be modified after creation.

#### Characteristics:
- **Resource Creation**: Create servers, databases, buckets, networks, etc.
- **Mutable**: Resources can be modified after initial creation
- **Multi-cloud Support**: Work across different cloud providers
- **State Management**: Track actual infrastructure state

#### Examples:
- **Terraform**: Most widely used, cloud-agnostic
- **CloudFormation**: AWS-specific provisioning tool
- **Azure Resource Manager (ARM)**: Microsoft Azure provisioning

---

## Terraform Overview

### What is Terraform?

**Terraform** is an open-source infrastructure provisioning tool that allows you to define cloud infrastructure using declarative configuration files. It supports multiple cloud providers including AWS, Azure, GCP, and others.

### Why Terraform?

1. **Multi-Cloud Support**: Single tool for AWS, Azure, GCP, and 100+ providers
2. **Declarative Language**: Describe desired state, not step-by-step procedures
3. **State Management**: Tracks infrastructure state for accurate updates
4. **Modular**: Organize code into reusable modules
5. **Community**: Large ecosystem with thousands of modules
6. **Learning Curve**: Relatively easy to learn compared to CloudFormation

### Terraform Provider

**Provider** is the main bridge between Terraform and cloud platforms. It:
- Establishes communication with cloud providers (AWS, Azure, GCP)
- Translates Terraform code into API calls
- Manages resource creation, updates, and deletions

Example:
```terraform
provider "aws" {
  region = "ap-south-1"
}
```

---

## Core Terraform Commands

### 1. `terraform init`
**Purpose**: Initialize Terraform working directory

**What it does**:
- Downloads and installs provider plugins
- Initializes backend for state storage
- Creates `.terraform` directory with plugin binaries
- Sets up configuration for remote state (if configured)

```bash
terraform init
```

---

### 2. `terraform plan`
**Purpose**: Preview changes before applying

**What it does**:
- Reads current state file
- Compares with configuration files
- Shows what will be created, modified, or destroyed
- Does NOT make actual changes

**Usage**:
```bash
terraform plan                              # Basic plan
terraform plan -var-file="prod.tfvars"     # With specific variables
terraform plan -out=tfplan                 # Save plan to file
```

**Output Format**:
- `+` = Resource will be created
- `-` = Resource will be destroyed
- `~` = Resource will be modified
- `-/+` = Resource will be replaced (destroyed then recreated)

---

### 3. `terraform validate`
**Purpose**: Check syntax and configuration validity

**What it does**:
- Validates HCL syntax
- Checks resource declarations
- Verifies variable definitions
- Does not check cloud provider credentials or resource availability

```bash
terraform validate
```

**Output**: Returns 0 if valid, non-zero if errors found.

---

### 4. `terraform fmt`
**Purpose**: Auto-format and align code

**What it does**:
- Standardizes indentation
- Aligns block structure
- Improves code readability
- Automatically applies changes

**Usage**:
```bash
terraform fmt                   # Format current directory
terraform fmt -recursive        # Format all .tf files recursively
terraform fmt -check           # Check without applying changes
```

---

### 5. `terraform apply`
**Purpose**: Create, update, or delete infrastructure based on configuration

**What it does**:
- Runs terraform plan internally
- Requests user approval (unless auto-approved)
- Creates/updates/deletes cloud resources
- Updates the state file

**Usage**:
```bash
terraform apply                                 # Standard apply with approval
terraform apply -auto-approve                  # Skip confirmation
terraform apply -var-file="prod.tfvars"       # Apply with specific variables
terraform apply -target=aws_instance.web      # Apply specific resource only
```

**Safety Feature**: Always shows a summary and asks for approval before making changes.

---

### 6. `terraform destroy`
**Purpose**: Delete all infrastructure created by Terraform

**What it does**:
- Deletes all resources defined in configuration
- Updates state file to reflect deleted resources
- Requires confirmation (unless auto-approved)
- Irreversible - data loss risk

**Usage**:
```bash
terraform destroy                              # Standard destroy with approval
terraform destroy -auto-approve               # Skip confirmation
terraform destroy -target=aws_instance.web   # Destroy specific resource only
```

**Warning**: Use with caution! This permanently deletes infrastructure.

---

### 7. Additional Useful Commands

#### `terraform state`
Manage and inspect the state file:
```bash
terraform state list                    # List all resources in state
terraform state show aws_instance.web  # Show specific resource details
terraform state rm aws_instance.old    # Remove resource from state
terraform state mv old new             # Rename resource
```

#### `terraform refresh`
**Deprecated** - Update state file with actual infrastructure state:
```bash
terraform refresh
```
**Note**: This is now integrated into `terraform apply` and `terraform plan`.

#### `terraform output`
Display module outputs:
```bash
terraform output                        # Show all outputs
terraform output instance_ip           # Show specific output
terraform output -json                # JSON format
```

---

## Terraform Architecture

### How Terraform Works

1. **Write**: Create `.tf` files with resource definitions
2. **Plan**: Run `terraform plan` to see what will happen
3. **Apply**: Run `terraform apply` to create resources
4. **Manage**: Update configurations and run plan/apply again
5. **Destroy**: Run `terraform destroy` to clean up

### File Types

- **`.tf` files**: Main configuration files (Terraform code)
- **`.tfvars` files**: Variable value files (environment-specific)
- **`terraform.tfstate`**: State file (current infrastructure state)
- **`terraform.tfstate.backup`**: Backup state file
- **`.terraform/`**: Directory containing provider plugins
- **`.terraform.lock.hcl`**: Lock file for provider version consistency

---

## Meta-Arguments

**Meta-arguments** are special arguments available in ANY resource, module, or data block. They control Terraform behavior without being provider-specific.

### 1. `count`
**Purpose**: Create multiple identical resources

**Syntax**:
```terraform
resource "aws_instance" "example" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "instance-${count.index}"
  }
}
```

**Usage**:
- `count.index`: 0-based index (0, 1, 2...)
- `count.value`: Current value in count
- Reference: `aws_instance.example[0]`, `aws_instance.example[1]`

**Limitation**: Changes in count position shift all resources (risky)

---

### 2. `for_each`
**Purpose**: Create multiple resources with different values

**Syntax**:
```terraform
variable "instances" {
  type = map(object({
    ami           = string
    instance_type = string
  }))
}

resource "aws_instance" "example" {
  for_each      = var.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type
  tags = {
    Name = each.key
  }
}
```

**Usage**:
- `each.key`: Map key
- `each.value`: Map value
- Reference: `aws_instance.example["web"]`

**Advantage**: More flexible and stable than count when resource keys change

---

### 3. `depends_on`
**Purpose**: Enforce resource creation order

**Syntax**:
```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  depends_on    = [aws_security_group.web]
}

resource "aws_security_group" "web" {
  name = "web-sg"
}
```

**Use Case**: When implicit dependencies (using resource references) aren't sufficient.

---

### 4. `lifecycle`
**Purpose**: Control resource creation, update, and deletion behavior

#### Sub-options:

**a) `create_before_destroy = true`**
- Creates new resource before destroying old one
- Reduces downtime for applications
- Useful for load-balanced services

```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  lifecycle {
    create_before_destroy = true
  }
}
```

**b) `ignore_changes`**
- Tells Terraform to ignore specific attribute changes
- Prevents unnecessary updates from external modifications

```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  lifecycle {
    ignore_changes = [tags]
  }
}
```

**c) `prevent_destroy = true`**
- Prevents resource deletion via `terraform destroy`
- Useful for critical resources (databases, important buckets)

```terraform
resource "aws_s3_bucket" "important" {
  bucket = "my-important-bucket"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

---

### 5. `provider`
**Purpose**: Use different provider configurations

**Syntax**:
```terraform
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

resource "aws_instance" "us" {
  provider      = aws.us-east-1
  ami           = var.ami_id
  instance_type = var.instance_type
}

resource "aws_instance" "eu" {
  provider      = aws.eu-west-1
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

---

## Advanced Features

### Terraform Target

The `target` flag allows applying or destroying **specific resources** instead of entire configuration.

**Syntax**:
```bash
terraform plan -target=aws_instance.web
terraform apply -target=aws_instance.web
terraform destroy -target=aws_instance.web
```

**Use Cases**:
- Fixing specific resources without affecting others
- Debugging particular resources
- Selective infrastructure updates

**Warning**: Can cause dependency issues if not careful.

---

### Terraform Replace

Forces resource replacement (destroy then recreate).

**Syntax**:
```bash
terraform apply -replace=aws_instance.web
```

**Difference from `create_before_destroy`**:
- `replace`: Destroys then creates (downtime risk)
- `create_before_destroy`: Creates then destroys (zero downtime)

---

### Parallelism

**Default**: Terraform creates up to 10 resources concurrently.

**Customize**:
```bash
terraform apply -parallelism=5    # Create 5 resources at a time
terraform apply -parallelism=1    # Sequential creation
```

**Use Case**: Some cloud providers have rate limits or ordering requirements.

---

### Terraform Import

Import existing cloud resources into Terraform state and configuration.

**Use Case**: You have manually created resources that need to be managed by Terraform.

**Process**:

**Step 1**: Define resource block in configuration
```terraform
resource "aws_instance" "imported" {
  ami           = "ami-0317b0f0a0144b137"
  instance_type = "t3.micro"
}
```

**Step 2**: Import existing resource into state
```bash
terraform import aws_instance.imported i-0f3ba09dddbabee65
```

**Step 3**: Update configuration to match actual resource
```terraform
resource "aws_instance" "imported" {
  ami                    = "ami-0317b0f0a0144b137"
  instance_type          = "t3.micro"
  key_name               = "my-key"
  vpc_security_group_ids = ["sg-12345678"]
  tags = {
    Name = "imported-instance"
  }
}
```

**Step 4**: Verify with plan
```bash
terraform plan
```

---

### Drift Detection

When infrastructure is manually modified outside of Terraform, it becomes "drifted" from the configuration.

**Detection Process**:
```bash
terraform plan    # Shows differences between code and actual state
```

**Resolution**:
1. Update configuration to match actual state
2. Use `refresh` to update state file
3. Reapply with `terraform apply`

---

## State Management

### What is State?

**State** is a JSON file that Terraform maintains to track the current state of your infrastructure. It's the "source of truth" for Terraform.

### State File Contents

```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "resources": [
    {
      "type": "aws_instance",
      "name": "web",
      "instances": [
        {
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0317b0f0a0144b137",
            "public_ip": "203.0.113.12"
          }
        }
      ]
    }
  ]
}
```

### State File Security

**⚠️ CRITICAL**: State files contain sensitive information:
- Database passwords
- Private keys
- API keys
- Resource IDs
- Configuration details

**Best Practices**:
- Never commit state files to version control
- Store in private S3 bucket with encryption
- Use state locking to prevent concurrent modifications
- Enable versioning on S3 bucket
- Restrict IAM access to state bucket

---

### Remote State Backend

Store state in centralized location for team collaboration.

#### S3 Backend Configuration

```terraform
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

**Configuration Details**:
- **bucket**: S3 bucket name (must exist)
- **key**: Path to state file within bucket
- **region**: Region where bucket is located
- **encrypt**: Enable server-side encryption
- **dynamodb_table**: Table for state locking

#### DynamoDB State Locking

Prevents concurrent `terraform apply` operations that could corrupt state.

**Create DynamoDB table**:
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

**Table Requirements**:
- Primary key named `LockID`
- Can be created manually or via Terraform

---

### State Commands

```bash
# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.web

# Remove resource from state (doesn't delete from cloud)
terraform state rm aws_instance.web

# Rename resource in state
terraform state mv aws_instance.web aws_instance.web_server

# Pull current remote state
terraform state pull > current.tfstate

# Push new state to backend
terraform state push new.tfstate
```

---

## Variables and Configuration

### What are Variables?

Variables allow you to parameterize Terraform configurations, making them reusable and reducing hardcoding.

### Variable Declaration

**File**: `variables.tf`

```terraform
variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
  default     = "ami-0317b0f0a0144b137"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to resources"
  default = {
    Environment = "dev"
    Project     = "terraform-learning"
  }
}
```

### Variable Types

```terraform
# String
variable "name" {
  type = string
}

# Number
variable "count" {
  type = number
}

# Bool
variable "enable_monitoring" {
  type = bool
}

# List
variable "availability_zones" {
  type = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

# Map
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}

# Object (Complex type)
variable "instance_config" {
  type = object({
    ami           = string
    instance_type = string
    count         = number
  })
}

# Any (Dynamic type)
variable "config" {
  type = any
}
```

### Variable Usage

**In configuration**:
```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count         = var.instance_count
  
  tags = var.tags
}
```

### Setting Variable Values

#### Method 1: Command-line Arguments
```bash
terraform apply -var="ami_id=ami-12345" -var="instance_type=t3.small"
```

#### Method 2: Variable Files (.tfvars)
**File**: `prod.tfvars`
```terraform
ami_id        = "ami-12345"
instance_type = "t3.large"
instance_count = 5
tags = {
  Environment = "production"
  Project     = "web-app"
}
```

**Usage**:
```bash
terraform apply -var-file="prod.tfvars"
```

#### Method 3: Environment Variables
```bash
export TF_VAR_ami_id="ami-12345"
export TF_VAR_instance_type="t3.small"
terraform apply
```

#### Method 4: Interactive Input
If variable has no default and isn't provided, Terraform will prompt.

```bash
terraform apply
# Terraform will ask: Enter a value for 'ami_id':
```

---

## Workspaces

### What are Workspaces?

**Workspaces** allow you to maintain multiple isolated states within a single configuration. Useful for managing different environments (dev, uat, prod) from one codebase.

### How Workspaces Work

- Each workspace has its own state file
- Switching workspaces changes which state is active
- Configuration remains the same, only state differs
- Use `.tfvars` files for environment-specific values

### Workspace Commands

```bash
# List all workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev
terraform workspace new uat
terraform workspace new prd

# Select workspace
terraform workspace select dev
terraform workspace select uat
terraform workspace select prd

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete dev
```

### Workspace State Structure

```
.
├── terraform.tfstate                 # Default workspace
└── terraform.tfstate.d/
    ├── dev/
    │   ├── terraform.tfstate
    │   └── terraform.tfstate.backup
    ├── uat/
    │   ├── terraform.tfstate
    │   └── terraform.tfstate.backup
    └── prd/
        ├── terraform.tfstate
        └── terraform.tfstate.backup
```

### Complete Workspace Workflow

**Step 1**: Initialize Terraform
```bash
terraform init
```

**Step 2**: Create workspaces
```bash
terraform workspace new dev
terraform workspace new uat
terraform workspace new prd
```

**Step 3**: For each environment, switch and apply
```bash
# Deploy to dev
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

# Deploy to uat
terraform workspace select uat
terraform apply -var-file="uat.tfvars"

# Deploy to prod
terraform workspace select prd
terraform apply -var-file="prod.tfvars"
```

### Example: Environment-specific Variables

**File**: `dev.tfvars`
```terraform
instance_type = "t3.micro"
instance_count = 1
environment = "development"
```

**File**: `prod.tfvars`
```terraform
instance_type = "t3.large"
instance_count = 3
environment = "production"
```

---

## Modules

### What are Modules?

**Modules** are containers for multiple resources that can be packaged and reused. They help organize infrastructure code into logical units and promote code reuse across projects.

### Benefits of Modules

1. **Reusability**: Create once, use in multiple projects
2. **Organization**: Logical grouping of related resources
3. **Maintainability**: Easy to update and manage
4. **Abstraction**: Hide complexity from users
5. **Consistency**: Standardized infrastructure patterns
6. **Sharing**: Share within organization or community

### Module Structure

```
terraform_modules/
├── main.tf              # Root configuration
├── variables.tf         # Root-level variables
├── outputs.tf           # Root-level outputs
├── backend.tf           # State backend config
│
├── ec2/                 # EC2 module
│   ├── main.tf          # Resource definitions
│   ├── variables.tf     # Module inputs
│   └── output.tf        # Module outputs
│
└── s3/                  # S3 module
    ├── main.tf          # Resource definitions
    ├── variables.tf     # Module inputs
    └── output.tf        # Module outputs
```

### Module Best Practices

**Module Main File**: Define all resources

```terraform
# ec2/main.tf
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags          = var.tags
}
```

**Module Variables**: Define module inputs

```terraform
# ec2/variables.tf
variable "ami_id" {
  type        = string
  description = "AMI ID for instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
```

**Module Outputs**: Expose important values

```terraform
# ec2/output.tf
output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of instance"
}

output "instance_id" {
  value = aws_instance.web.id
}
```

### Using Modules (Root Configuration)

```terraform
# main.tf
provider "aws" {
  region = "ap-south-1"
}

module "ec2_instance" {
  source        = "./ec2"
  ami_id        = var.ami_id           # Must pass explicitly
  instance_type = var.instance_type
  tags          = var.tags
}

module "s3_bucket" {
  source = "./s3"
  # Accepts variables from module's variables.tf
}

# Access module outputs
output "web_instance_ip" {
  value = module.ec2_instance.public_ip
}
```

### Root Configuration Variables

```terraform
# variables.tf (root)
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "tags" {
  type = map(string)
}
```

---

## Provisioning

### What is Provisioning?

**Provisioning** refers to installing software and configuring systems on launched instances. Terraform supports two types of provisioners.

### 1. Remote-exec Provisioner

Executes commands on remote instances via SSH or WinRM.

#### Use Case
Run commands to install packages, start services, or perform initial setup on instance launch.

#### Example

```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  # SSH key for authentication
  key_name               = "my-keypair"
  vpc_security_group_ids = ["sg-0a1d54e4e39ac674f"]
  
  tags = {
    Name = "web-server"
  }

  # Connection configuration
  connection {
    type        = "ssh"
    user        = "ec2-user"                    # For Amazon Linux
    private_key = file("~/.ssh/my-key.pem")
    host        = self.public_ip
  }

  # Remote execution
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<h1>Hello World</h1>' | sudo tee /var/www/html/index.html"
    ]
  }
}

output "web_server_ip" {
  value = aws_instance.web.public_ip
}
```

#### Connection Block Options

```terraform
connection {
  type        = "ssh"                   # SSH or WinRM
  user        = "ec2-user"              # SSH user
  private_key = file("~/.ssh/key.pem") # SSH key file
  host        = self.public_ip          # Target IP/hostname
  port        = 22                      # SSH port (default: 22)
  timeout     = "5m"                    # Connection timeout
}
```

#### Remote-exec Options

```terraform
# Inline commands
provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install docker -y",
    "sudo systemctl start docker"
  ]
}

# Script file
provisioner "remote-exec" {
  script = "./scripts/install.sh"
}

# Multiple scripts
provisioner "remote-exec" {
  scripts = [
    "./scripts/install.sh",
    "./scripts/configure.sh"
  ]
}
```

---

### 2. Local-exec Provisioner

Executes commands on the machine running Terraform (your local machine).

#### Use Case
Trigger local scripts, webhooks, or integrations after resource creation.

#### Example

```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory.txt"
  }
  
  provisioner "local-exec" {
    command = "bash ./scripts/notify-slack.sh '${self.public_ip}'"
  }
}
```

---

### Provisioner Best Practices

⚠️ **Important**: Provisioners should be a last resort. Prefer:
1. **User Data Scripts**: EC2 `user_data` attribute
2. **Server Templates**: Pre-built AMIs with software
3. **Configuration Management**: Ansible, Puppet, Chef

#### Better Alternative: User Data

```terraform
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))
}
```

**File**: `user_data.sh`
```bash
#!/bin/bash
sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

---

## Debugging

### TF_LOG Environment Variable

Control logging verbosity for troubleshooting.

#### Log Levels (from least to most verbose)
1. **ERROR**: Only errors
2. **WARN**: Warnings and errors
3. **INFO**: General information
4. **DEBUG**: Detailed debugging information
5. **TRACE**: Extremely detailed, includes API calls

#### Usage

```bash
# Enable DEBUG logging
export TF_LOG=DEBUG
terraform apply

# Enable TRACE logging
export TF_LOG=TRACE
terraform plan

# Log to file
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
terraform apply

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

#### Log File Inspection

```bash
tail -f /tmp/terraform.log          # Follow logs in real-time
grep ERROR /tmp/terraform.log       # Find errors
grep "aws_instance" /tmp/terraform.log  # Find specific resource logs
```

---

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Error: Unsupported block type" | Invalid syntax | Check HCL syntax, use `terraform fmt` |
| "Error: Missing required argument" | Missing required variable | Define variable or pass via CLI |
| "Error: Provider not found" | Plugin not installed | Run `terraform init` |
| "Error: Failed to parse arguments" | Invalid variable type | Check variable type matches value |
| "Error: Invalid provider configuration" | Missing credentials | Run `aws configure` or set env vars |
| "Error: Address already in use" | Resource already exists | Use `terraform import` or change name |
| "Error: Failed to create S3 bucket" | Bucket name taken globally | Choose unique bucket name |

---

## Project Structure

### Complete Project Organization

```
terraform_project/
│
├── .github/
│   └── copilot-instructions.md      # AI agent guidelines
│
├── main.tf                          # Root configuration
├── variables.tf                     # Root-level variables
├── outputs.tf                       # Root-level outputs
├── backend.tf                       # State backend config
│
├── dev.tfvars                       # Dev environment variables
├── uat.tfvars                       # UAT environment variables
├── prod.tfvars                      # Prod environment variables
│
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── networking/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/
│   ├── install.sh                   # Installation scripts
│   └── configure.sh                 # Configuration scripts
│
├── .gitignore                       # Git ignore rules
├── README.md                        # Project documentation
└── terraform.tfstate                # State file (DO NOT COMMIT)
```

### .gitignore for Terraform

```
# State files
*.tfstate
*.tfstate.*

# Crash files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
!example.tfvars

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore plan files
*.tfplan

# Local .terraform directories
**/.terraform/*

# .tfstate files
**/.tfstate

# Crash log files
crash.log
crash.*.log

# Ignore any .tfvars files that are generated automatically
*.auto.tfvars

# IDE
.idea/
*.swp
*.swo
*~
.DS_Store
```

---

## Key Region Configuration

This project uses **ap-south-1 (Asia Pacific - Mumbai)** region throughout.

### Region-Specific Values

**Important**: AMI IDs, availability zones, and other resources are region-specific.

#### Example: Ubuntu 22.04 LTS AMIs by Region
- **ap-south-1** (Mumbai): `ami-0317b0f0a0144b137`
- **us-east-1** (N. Virginia): `ami-0c55b159cbfafe1f0`
- **eu-west-1** (Ireland): `ami-0d2a4a5d805231daa`

To find correct AMI for your region:
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --region ap-south-1 \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId'
```

---

## Working with AWS Credentials

### Configure AWS CLI

```bash
aws configure

# Enter:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region: ap-south-1
# Default output format: json
```

### Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

### AWS Credentials File

**File**: `~/.aws/credentials`
```
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key

[production]
aws_access_key_id = prod-access-key
aws_secret_access_key = prod-secret-key
```

### Using Specific Credential Profile

```terraform
provider "aws" {
  region  = "ap-south-1"
  profile = "production"
}
```

---

## Quick Start Guide

### 1. Initialize Project
```bash
cd terraform_modules
terraform init
```

### 2. Create Environment Variables File
```bash
# Create prod.tfvars
cat > prod.tfvars << EOF
ami_id        = "ami-0317b0f0a0144b137"
instance_type = "t3.micro"
tags = {
  Environment = "production"
  Project     = "terraform-learning"
}
EOF
```

### 3. Plan Changes
```bash
terraform plan -var-file="prod.tfvars"
```

### 4. Apply Configuration
```bash
terraform apply -var-file="prod.tfvars"
```

### 5. View Outputs
```bash
terraform output
```

### 6. Destroy When Done
```bash
terraform destroy -var-file="prod.tfvars"
```

---

## Summary

This comprehensive guide covers:

✅ IaC concepts and tool categories  
✅ Terraform core commands and workflows  
✅ Advanced features (target, replace, parallelism)  
✅ State management and remote backends  
✅ Variables, workspaces, and modules  
✅ Provisioning and debugging  
✅ Real-world project structure  

**Next Steps**:
1. Explore `terraform_modules/` for modular design patterns
2. Try `terraform_workspace/` for multi-environment setup
3. Practice `terraform-import/` for managing existing resources
4. Review state management best practices
5. Build your own modules for organization-specific patterns

---

## Additional Resources

- [Terraform Official Documentation](https://www.terraform.io/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Module Registry](https://registry.terraform.io/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)

---

**Last Updated**: February 2026  
**Project Focus**: AWS Infrastructure Provisioning with Terraform
**Notes Provider**: Harideep Janga (Devops & AWS Learner)
**LinkedIN** : https://www.linkedin.com/in/harideep-janga-227639294/?skipRedirect=true

**Twitter**: https://x.com/cloudinsteps
