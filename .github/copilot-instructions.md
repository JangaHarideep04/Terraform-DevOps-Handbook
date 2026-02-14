# Copilot Instructions for Terraform AWS Infrastructure

## Project Overview

This is a **learning-focused Terraform project** demonstrating Infrastructure as Code (IaC) best practices for AWS provisioning. It contains multiple independent examples and one primary modular project (`terraform_modules/`) that serves as the reference implementation.

**Core Purpose**: Provision EC2 instances and S3 buckets on AWS ap-south-1 (Mumbai region) using modular, reusable Terraform configurations.

---

## Architecture & Key Directories

### Primary Project: `terraform_modules/` (Reference Implementation)

**Structure**:
```
terraform_modules/
├── main.tf              # Root configuration - provider & module orchestration
├── variables.tf         # Root-level input variables
├── backend.tf           # S3 state backend with encryption & locking
├── ec2/                 # EC2 compute module
│   ├── main.tf          # aws_instance resource
│   ├── variables.tf      # ami_id, instance_type, tags inputs
│   └── output.tf        # Public IP output
└── s3/                  # S3 storage module
    ├── main.tf          # aws_s3_bucket resource
    ├── variables.tf      # aws_s3 (bucket name) input
    └── output.tf        # Bucket name output
```

**Key Pattern**: **Modular design** - each module is self-contained with separate input variables, resources, and outputs. Root `main.tf` orchestrates by calling modules with parameters.

**State Management**: Uses remote S3 backend (`bucket = "my-terraform-s3-bucket-harideep"`). Backend must exist before running `terraform apply`.

---

### Learning Examples

- `terraform exec/` - Demonstrates basic `terraform` CLI usage
- `terraform variable/` - Shows variable definition and passing patterns
- `terraform_output/` - Illustrates output block syntax for exposing values
- `terraform_workspace/` - Multi-environment setup using `terraform workspace` with `.tfvars` files (dev/uat/prod)
- `terraform-import/` - Import existing AWS resources into Terraform state

---

## Critical Conventions & Patterns

### 1. **Module Inputs & Outputs**

Each module follows strict input/output boundaries:
- **EC2 Module**: Accepts `ami_id`, `instance_type`, `tags` → Outputs public IP
- **S3 Module**: Accepts `aws_s3` (bucket name) → Outputs bucket name

Variables are **not** auto-populated; root config must explicitly pass them:
```terraform
module "ec2_instance" {
  source        = "./ec2"
  ami_id        = var.ami_id              # Must pass variable
  instance_type = var.instance_type
  tags          = var.tags
}
```

### 2. **Variable Usage in root `terraform_modules/`**

Root-level `variables.tf` declares abstract inputs; `.tfvars` files override them:
```bash
terraform apply -var-file="prod.tfvars"   # Use prod values
terraform apply -var-file="dev.tfvars"    # Use dev values
```

**Critical**: Variables must be defined in `variables.tf` before use. Missing variable definitions cause `terraform plan` to fail.

### 3. **Naming Conventions**

- **S3 Bucket**: Must be globally unique. Project uses descriptive pattern: `my-terraform-s3-bucket-harideep`
- **EC2 Resources**: Use snake_case for resource names: `aws_instance.module_ec2`
- **Tags**: Applied via `var.tags` map; use consistent tagging for cost tracking and automation

### 4. **Region Configuration**

All resources target **ap-south-1 (Asia Pacific - Mumbai)**. Configured in:
- Root `main.tf`: `provider "aws" { region = "ap-south-1" }`
- Backend `s3`: `region = "ap-south-1"` (must match S3 bucket region)
- Examples use Ubuntu 22.04 LTS AMI: `ami-0317b0f0a0144b137` (specific to ap-south-1)

**Critical**: Changing region requires updating:
1. Provider region
2. Backend region
3. AMI ID (AMIs are region-specific)

### 5. **Backend & State Management**

S3 backend enables team collaboration & state locking:
- **Encrypt**: `encrypt = true` (KMS encryption for sensitive data)
- **Bucket**: Must exist before `terraform init`
- **DynamoDB Lock Table**: Optional but recommended (prevents concurrent operations)

When troubleshooting state issues:
- State files live in `terraform.tfstate` (tracked in git for learning; excluded in production)
- Backup files (`terraform.tfstate.backup`) auto-created on apply
- Workspace-specific states in `terraform.tfstate.d/{workspace}/`

---

## Developer Workflows

### Standard Terraform Operations

```bash
# Initialize workspace (downloads provider plugins, configures backend)
terraform init

# Preview changes (shows resource additions/modifications/deletions)
terraform plan
terraform plan -var-file="prod.tfvars"

# Apply infrastructure changes (requires approval)
terraform apply
terraform apply -var-file="prod.tfvars"

# Destroy infrastructure (destructive - requires approval)
terraform destroy
terraform destroy -var-file="prod.tfvars"
```

### Multi-Workspace Operations (terraform_workspace/)

```bash
# List available workspaces
terraform workspace list

# Switch workspace
terraform workspace select dev
terraform workspace select uat
terraform workspace select prd

# Create new workspace
terraform workspace new staging

# Apply workspace-specific variables
terraform apply -var-file="dev.tfvars"
```

### Resource Import (terraform-import/)

Import existing AWS resources into Terraform state:
```bash
# Import existing EC2 instance
terraform import aws_instance.terraform-test i-1234567890abcdef0

# Now manage imported resource with Terraform
terraform plan
```

### Common Debugging

```bash
# View current state
terraform state list
terraform state show aws_instance.module_ec2

# Validate syntax
terraform fmt -recursive        # Auto-format all .tf files
terraform validate             # Check for errors
```

---

## Key Dependencies & Integration Points

### AWS Credentials

Terraform requires AWS credentials. Configure via:
```bash
aws configure                               # Interactive setup
export AWS_ACCESS_KEY_ID=xxx               # Or environment variables
export AWS_SECRET_ACCESS_KEY=yyy
```

Credentials needed for:
- EC2 instance provisioning
- S3 bucket creation
- State backend access

### EC2 Instance Requirements

- **AMI**: Ubuntu 22.04 LTS (`ami-0317b0f0a0144b137`) - region-specific
- **Instance Type**: `t3.micro` (free tier eligible, 1 vCPU, 1GB RAM)
- **Access**: SSH via public IP output from module

### S3 Bucket Constraints

- **Global Uniqueness**: Bucket names must be unique across all AWS accounts
- **Naming Rules**: 3-63 chars, lowercase only, no consecutive hyphens
- **Common Error**: "BucketAlreadyExists" when name is taken—choose different name in `.tfvars`

---

## File-Specific Guidance

| File | Purpose | Key Patterns |
|------|---------|--------------|
| `main.tf` (root) | Orchestrate modules, configure provider | Module declarations with explicit variable passing |
| `variables.tf` | Declare abstract inputs | No defaults (except in examples); all types explicit |
| `backend.tf` | Remote state config | S3 bucket must pre-exist; encryption required |
| `outputs.tf` | Expose module results | Aggregates module outputs for root-level access |
| `.tfvars` files | Environment-specific values | One file per environment (dev/uat/prod) |

---

## Common Pitfalls & Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| "Invalid or unsupported provider" | Plugin not downloaded | Run `terraform init` |
| "S3 bucket does not exist" | Backend bucket not created | Manually create S3 bucket in AWS first |
| "No valid AWS credentials" | Missing credentials | Run `aws configure` or set env vars |
| "BucketAlreadyExists" | S3 name globally taken | Change bucket name in variables/.tfvars |
| "Invalid AMI ID" | AMI not available in region | Verify AMI exists in ap-south-1 region |
| "Module not found" | Invalid source path | Check relative paths in module `source` attribute |

---

## When Enhancing This Codebase

1. **Adding New Modules**: Create `module-name/` directory with `main.tf`, `variables.tf`, `outputs.tf`
2. **Adding Resources**: Update module `main.tf` and expose outputs for module visibility
3. **New Environments**: Create `.tfvars` file (e.g., `staging.tfvars`) and use `terraform apply -var-file="staging.tfvars"`
4. **Variable Changes**: Update `variables.tf` with type and description, then reference in resource blocks
5. **State Migrations**: Avoid manually editing `.tfstate` files; use `terraform state` commands instead
