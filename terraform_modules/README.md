# Terraform AWS Infrastructure Project

## Project Overview

This is a **modular Terraform project** that provisions cloud infrastructure on Amazon Web Services (AWS). The project demonstrates Infrastructure as Code (IaC) best practices by organizing AWS resources into reusable modules.

### What We Built

This project creates and manages:
- **1 EC2 Instance** - A virtual machine running Ubuntu 22.04 LTS
- **1 S3 Bucket** - An object storage container for files and data

All infrastructure is defined, versioned, and deployed through Terraform configuration files.

---

## Project Structure

```
terraform_modules/
├── main.tf                          # Root configuration file
├── terraform.tfstate                # Current state file (auto-generated)
├── terraform.tfstate.backup         # Backup state file (auto-generated)
│
├── ec2/                             # EC2 module directory
│   ├── main.tf                      # EC2 resource definitions
│   ├── variables.tf                 # EC2 input variables
│   └── output.tf                    # EC2 output values
│
└── s3/                              # S3 module directory
    ├── main.tf                      # S3 resource definitions
    ├── variables.tf                 # S3 input variables
    └── output.tf                    # S3 output values
```

### Directory Explanation

- **Root Directory (`terraform_modules/`)**: Contains the main configuration that orchestrates modules
- **EC2 Module (`ec2/`)**: Self-contained module for EC2 instance provisioning
- **S3 Module (`s3/`)**: Self-contained module for S3 bucket provisioning
- **State Files**: Track infrastructure state for updates and deletions

---

## File Descriptions

### Root Configuration: `main.tf`

**Purpose**: Orchestrates the entire infrastructure by defining the AWS provider and calling modules.

**Key Components**:
- AWS provider configuration (region: ap-south-1 / Mumbai)
- EC2 module declaration
- S3 module declaration
- Root-level outputs that expose module results

**Why This Approach?**
Using modules creates reusable, maintainable code. Each module is self-contained and can be tested independently.

---

### EC2 Module - Virtual Machines

#### `ec2/main.tf`
Defines the EC2 instance resource with:
- **AMI (Amazon Machine Image)**: Ubuntu 22.04 LTS (ami-0317b0f0a0144b137)
- **Instance Type**: t3.micro (1 vCPU, 1 GB memory, eligible for free tier)

#### `ec2/variables.tf`
Defines customizable inputs:
- `aws_instance`: Instance type (default: t3.micro)
- `ami_id`: Operating system image ID (default: Ubuntu 22.04 LTS)

#### `ec2/output.tf`
Exposes the EC2 instance's public IP address for remote access (SSH, web services).

**Use Cases**:
- Web servers
- Application servers
- Development/testing environments
- Any workload requiring a Linux/Windows machine

---

### S3 Module - Object Storage

#### `s3/main.tf`
Defines the S3 bucket resource with:
- **Bucket Name**: my-terraform-s3-bucket-harideep
- **Global Uniqueness**: S3 bucket names must be unique across all AWS accounts

#### `s3/variables.tf`
Defines customizable input:
- `aws_s3`: S3 bucket name (must be globally unique)

#### `s3/output.tf`
Exposes the S3 bucket name for reference in other configurations or documentation.

**Use Cases**:
- Static website hosting
- Backup and archival storage
- Data lakes
- Log aggregation
- Media file distribution

---

## How It Works

### Terraform Workflow

1. **Initialization** (`terraform init`)
   - Downloads AWS provider plugins
   - Sets up local state management
   - Prepares the working directory

2. **Planning** (`terraform plan`)
   - Analyzes configuration files
   - Compares with current state
   - Displays proposed changes (Add/Update/Delete)

3. **Applying** (`terraform apply`)
   - Creates/updates resources on AWS
   - Updates the local state file
   - Displays output values

4. **Destroying** (`terraform destroy`)
   - Removes all created resources
   - Updates the local state file

### State Management

Terraform maintains a `terraform.tfstate` file that tracks:
- All created resources
- Their current configuration
- Their relationship dependencies

**Important**: This file contains sensitive information and should be:
- Stored securely
- Backed up regularly
- Never committed to version control without encryption
- Managed with remote state (AWS S3, Terraform Cloud) in production

---

## Quick Start Guide

### Prerequisites

1. **AWS Account**: Create free tier account at [aws.amazon.com](https://aws.amazon.com)
2. **AWS Credentials**: Configure via `aws configure` or environment variables
3. **Terraform**: Install from [terraform.io](https://www.terraform.io/downloads.html)
4. **AWS CLI**: Install from [aws.amazon.com/cli](https://aws.amazon.com/cli/)

### Step-by-Step Deployment

```bash
# 1. Navigate to project directory
cd /Users/harideepjanga/Downloads/Terraform/terraform_modules

# 2. Initialize Terraform
terraform init

# 3. Review what will be created
terraform plan

# 4. Create the infrastructure
terraform apply -auto-approve

# 5. View outputs
terraform output

# 6. Access your EC2 instance
ssh -i your-key-pair.pem ubuntu@<ec2-public-ip>

# 7. To destroy all resources when done
terraform destroy -auto-approve
```

---

## Configuration Details

### AWS Region
**Current**: ap-south-1 (Asia Pacific - Mumbai)

To change region:
1. Update `provider.aws.region` in `main.tf`
2. Update `ami_id` to match new region (AMI IDs are region-specific)
3. Run `terraform plan` to review changes
4. Run `terraform apply` to update

### EC2 Instance Details

| Property | Value | Notes |
|----------|-------|-------|
| Instance Type | t3.micro | Burstable, free tier eligible |
| vCPU | 1 | Single processor core |
| Memory | 1 GB | Suitable for light workloads |
| OS | Ubuntu 22.04 LTS | Long-term support, widely used |
| Public IP | Dynamic | Changes if instance is stopped/started |
| Cost | ~$0.01/hour | (pricing varies by region) |

### S3 Bucket Details

| Property | Value | Notes |
|----------|-------|-------|
| Bucket Name | my-terraform-s3-bucket-harideep | Globally unique, must change if taken |
| Storage Class | Standard | General-purpose, high performance |
| Availability | 99.99% | Highly reliable |
| Durability | 99.999999999% | 11 nines durability |
| Cost | Pay-as-you-go | $0.023/GB/month for storage |

---

## Customization Examples

### Change Instance Type

Edit `ec2/variables.tf`:
```terraform
default = "t3.small"  # 2 vCPU, 2 GB memory
```

Or override at apply time:
```bash
terraform apply -var="aws_instance=t3.medium"
```

### Change S3 Bucket Name

Edit `s3/variables.tf`:
```terraform
default = "my-unique-bucket-name-2024"
```

Note: Bucket name must be globally unique and follow naming rules.

### Change Operating System

Edit `ec2/variables.tf` with a different AMI ID:
```terraform
# Amazon Linux 2
default = "ami-070f61474c7315e38"

# Ubuntu 20.04 LTS
default = "ami-0c1a7f89451184c8b"
```

---

## Outputs

After `terraform apply`, the following outputs are displayed:

```
Outputs:

ec2_public_ip = "15.206.69.194"
s3_name = "my-terraform-s3-bucket-harideep"
```

These values can be:
- Viewed anytime with: `terraform output`
- Referenced in other configurations
- Exported to JSON: `terraform output -json`

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize working directory |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Create/update resources |
| `terraform apply -auto-approve` | Apply without confirmation prompt |
| `terraform destroy` | Delete all resources |
| `terraform output` | Display output values |
| `terraform output -json` | Display outputs as JSON |
| `terraform state list` | List all managed resources |
| `terraform state show <resource>` | Show resource details |
| `terraform validate` | Validate configuration syntax |
| `terraform fmt` | Format code to Terraform standards |
| `terraform console` | Interactive console for expressions |

---

## Troubleshooting

### Error: "Unsupported attribute"
- **Cause**: Trying to access invalid attributes on resources
- **Solution**: Check AWS provider documentation for correct attribute names

### Error: "Bucket name already exists"
- **Cause**: S3 bucket names are globally unique across all AWS accounts
- **Solution**: Change the bucket name in `s3/variables.tf`

### Error: "InvalidAMIID.NotFound"
- **Cause**: AMI ID doesn't exist in the specified region
- **Solution**: Verify AMI ID exists in the region, or update `ec2/variables.tf`

### No Outputs Displayed
- **Cause**: Outputs not properly declared or module outputs not referenced
- **Solution**: Ensure `main.tf` contains output blocks referencing modules

### Resource Doesn't Get Created
- **Cause**: Syntax errors or invalid configurations
- **Solution**: Run `terraform validate` to check for errors, then `terraform plan`

---

## Best Practices Used

✅ **Modular Design**: Separate EC2 and S3 into reusable modules  
✅ **Variables**: Input variables for easy customization  
✅ **Outputs**: Expose important values for external use  
✅ **Descriptions**: Document every variable and output  
✅ **Comments**: Inline comments explaining resource configuration  
✅ **Naming Conventions**: Clear, descriptive resource names  
✅ **State Management**: Track infrastructure state for consistency  
✅ **Single Responsibility**: Each module has one primary purpose  

---

## Security Considerations

⚠️ **Important Security Notes**:

1. **State File**: Contains sensitive information
   - Don't commit to version control
   - Use remote state (S3 + DynamoDB) in production
   - Enable encryption

2. **AWS Credentials**: Protect your credentials
   - Use IAM roles instead of hardcoded keys
   - Store credentials securely
   - Rotate keys regularly

3. **EC2 Security Groups**: Currently allows all traffic
   - Should be restricted to specific ports (22 for SSH, 80 for HTTP, etc.)
   - Use security group rules for fine-grained access

4. **S3 Bucket**: Currently has default (open) permissions
   - Consider enabling encryption
   - Enable versioning for data protection
   - Configure bucket policies for access control

---

## Production Checklist

Before deploying to production:

- [ ] Use remote state (AWS S3 + DynamoDB)
- [ ] Enable state file encryption
- [ ] Set up proper AWS IAM roles and policies
- [ ] Configure security groups with least privilege
- [ ] Enable S3 bucket encryption and versioning
- [ ] Set up backup strategies
- [ ] Enable CloudTrail for audit logging
- [ ] Plan disaster recovery procedures
- [ ] Use Terraform workspaces for dev/staging/prod separation
- [ ] Implement state locking to prevent concurrent modifications

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/best-practices)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)

---

## Project Goals Achieved

✅ **Infrastructure as Code**: Defined cloud resources in version-controllable code  
✅ **Modularity**: Created reusable EC2 and S3 modules  
✅ **Automation**: Eliminated manual AWS console operations  
✅ **Reproducibility**: Can recreate identical infrastructure anywhere  
✅ **Scalability**: Can easily add/modify resources  
✅ **Documentation**: Comprehensive comments and README  
✅ **Best Practices**: Followed Terraform conventions and standards  

---

## Support & Contributions

For questions or improvements:
1. Review Terraform and AWS documentation
2. Check the comments in configuration files
3. Run `terraform validate` to catch syntax errors
4. Use `terraform plan` to preview changes before applying

---

**Last Updated**: February 14, 2026  
**Terraform Version**: 1.x (compatible with latest)  
**AWS Region**: ap-south-1 (Mumbai)
