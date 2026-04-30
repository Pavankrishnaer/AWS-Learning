# Terraform Guide

A standalone reference for installing Terraform, configuring AWS credentials, and working with Terraform commands. Everything you need to get from zero to `terraform apply`.

---

## Table of Contents

- [Installation — macOS (Homebrew)](#installation--macos-via-homebrew)
- [Installation — Windows (Chocolatey)](#installation--windows-via-chocolatey)
- [AWS Credentials Setup](#aws-credentials-setup)
- [How Terraform Loads Files](#how-terraform-loads-files)
- [Terraform Workflow](#terraform-workflow)
- [Commands Reference](#commands-reference)
- [State Management](#state-management)
- [Tips & Best Practices](#tips--best-practices)

---

## Installation — macOS (via Homebrew)

### Step 1 — Install Homebrew

If Homebrew is not already installed on your machine:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2 — Add the HashiCorp tap

```bash
brew tap hashicorp/tap
```

### Step 3 — Install Terraform

```bash
brew install hashicorp/tap/terraform
```

### Step 4 — Verify the installation

```bash
terraform -version
```

Expected output:

```
Terraform v1.x.x
on darwin_amd64
```

### Keeping Terraform up to date

```bash
brew update
brew upgrade hashicorp/tap/terraform
```

---

## Installation — Windows (via Chocolatey)

Chocolatey is the recommended package manager for Windows, similar to Homebrew on macOS.

### Step 1 — Install Chocolatey

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Close and reopen PowerShell after installation.

### Step 2 — Install Terraform

```powershell
choco install terraform -y
```

### Step 3 — Verify the installation

```powershell
terraform -version
```

Expected output:

```
Terraform v1.x.x
on windows_amd64
```

### Keeping Terraform up to date

```powershell
choco upgrade terraform -y
```

---

### Alternative — Manual install (no package manager)

If you prefer not to use Chocolatey:

1. Go to [https://developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install)
2. Download the **Windows AMD64** zip file
3. Extract `terraform.exe` to a folder, e.g. `C:\terraform`
4. Add that folder to your system `PATH`:
   - Open **Start** → search `Environment Variables`
   - Under **System variables**, select `Path` → click **Edit**
   - Click **New** and add `C:\terraform`
   - Click **OK** to save
5. Open a new Command Prompt or PowerShell and verify:

```powershell
terraform -version
```

---

## AWS Credentials Setup

Terraform needs AWS credentials to provision resources. Choose one of the options below.

### Option A — AWS CLI (recommended)

**Install the AWS CLI:**

macOS:
```bash
brew install awscli
```

Windows:
```powershell
choco install awscli -y
```

Or download the MSI installer from [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)

**Configure your credentials:**

```bash
aws configure
```

You will be prompted for:

```
AWS Access Key ID:     <your-access-key-id>
AWS Secret Access Key: <your-secret-access-key>
Default region name:   us-east-1
Default output format: json
```

Credentials are stored at `~/.aws/credentials` (macOS/Linux) or `C:\Users\<you>\.aws\credentials` (Windows) and picked up automatically by Terraform.

**Verify the configuration:**

```bash
aws sts get-caller-identity
```

---

### Option B — Environment Variables

Useful for CI/CD pipelines or when you don't want to persist credentials to disk.

macOS / Linux:
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Add these to your `~/.zshrc` or `~/.bash_profile` to persist them across sessions.

Windows (PowerShell):
```powershell
$env:AWS_ACCESS_KEY_ID="your-access-key-id"
$env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
$env:AWS_DEFAULT_REGION="us-east-1"
```

To persist permanently on Windows, use `setx` in Command Prompt:
```cmd
setx AWS_ACCESS_KEY_ID "your-access-key-id"
setx AWS_SECRET_ACCESS_KEY "your-secret-access-key"
setx AWS_DEFAULT_REGION "us-east-1"
```

> ⚠️ `setx` changes only take effect in new terminal windows, not the current one.

---

### Option C — AWS Profile (multiple accounts)

If you manage multiple AWS accounts, you can use named profiles:

```bash
aws configure --profile my-profile-name
```

macOS / Linux — tell Terraform to use that profile:
```bash
export AWS_PROFILE=my-profile-name
```

Windows (PowerShell):
```powershell
$env:AWS_PROFILE="my-profile-name"
```

---

## How Terraform Loads Files

Terraform automatically reads **all `.tf` files** in the working directory and merges them into one combined configuration. The file names don't matter to Terraform — they are purely a convention to keep things organized.

```
terraform apply
    │
    ├── reads main.tf        → knows what resources to create
    ├── reads variables.tf   → knows the input values
    └── reads outputs.tf     → knows what to print after apply
```

A typical project structure looks like this:

```
.
├── main.tf          # Resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value declarations
├── .gitignore       # Files to exclude from version control
├── README.md        # Project documentation
└── TERRAFORM_GUIDE.md
```

### How outputs work

After `terraform apply` completes, Terraform automatically prints everything defined in `outputs.tf`:

```
Outputs:

instance_id        = "i-0abc123..."
instance_public_ip = "54.123.45.67"
```

You can also retrieve outputs at any time after apply without re-running anything:

```bash
terraform output                        # print all outputs
terraform output instance_public_ip     # print a specific output
```

### How variables work

Variables declared in `variables.tf` can be overridden at apply time without editing any files:

```bash
terraform apply -var="instance_type=t3.micro"
```

Or by creating a `terraform.tfvars` file (not committed to Git):

```hcl
instance_type = "t3.micro"
key_name      = "my-key"
```

Terraform picks up `terraform.tfvars` automatically if it exists in the working directory.

---

## Terraform Workflow

The standard Terraform lifecycle follows four steps:

```
terraform init → terraform plan → terraform apply → terraform destroy
```

### 1. `terraform init`

Initializes the working directory. Downloads the required provider plugins (e.g. AWS) defined in `required_providers`.

```bash
terraform init
```

Run this once when you first clone the repo, and again any time you add or change providers.

---

### 2. `terraform validate`

Checks that the configuration is syntactically valid without connecting to AWS.

```bash
terraform validate
```

---

### 3. `terraform fmt`

Formats all `.tf` files in the current directory to the canonical Terraform style.

```bash
terraform fmt
```

Use `-recursive` to format nested directories:

```bash
terraform fmt -recursive
```

---

### 4. `terraform plan`

Generates an execution plan — shows exactly what Terraform will create, change, or destroy. No changes are applied.

```bash
terraform plan
```

Save the plan to a file (useful for CI/CD or audit trails):

```bash
terraform plan -out=tfplan
```

---

### 5. `terraform apply`

Applies the changes to reach the desired state. Prompts for confirmation before proceeding.

```bash
terraform apply
```

Apply a saved plan file (skips the confirmation prompt):

```bash
terraform apply tfplan
```

Skip the confirmation prompt entirely:

```bash
terraform apply -auto-approve
```

---

### 6. `terraform destroy`

Destroys all infrastructure managed by the current configuration. Prompts for confirmation.

```bash
terraform destroy
```

Skip the confirmation prompt:

```bash
terraform destroy -auto-approve
```

---

## Commands Reference

| Command | Description |
|---|---|
| `terraform init` | Initialize directory, download providers |
| `terraform validate` | Check syntax without connecting to AWS |
| `terraform fmt` | Format `.tf` files to canonical style |
| `terraform plan` | Preview changes before applying |
| `terraform plan -out=tfplan` | Save plan to a file |
| `terraform apply` | Create or update infrastructure |
| `terraform apply tfplan` | Apply a saved plan file |
| `terraform apply -auto-approve` | Apply without confirmation prompt |
| `terraform destroy` | Remove all managed infrastructure |
| `terraform destroy -auto-approve` | Destroy without confirmation prompt |
| `terraform show` | Display current state in human-readable format |
| `terraform output` | Print all output values |
| `terraform output <name>` | Print a specific output value |
| `terraform state list` | List all resources tracked in state |
| `terraform state show <resource>` | Show details of a specific resource |
| `terraform refresh` | Sync state file with real infrastructure |
| `terraform graph` | Output a visual dependency graph (DOT format) |
| `terraform version` | Show the installed Terraform version |

---

## State Management

Terraform tracks all managed resources in a **state file** (`terraform.tfstate`). This file is critical — never delete it manually.

### Local state (default)

State is stored in `terraform.tfstate` in your working directory. Suitable for solo projects.

### Remote state (recommended for teams)

Store state remotely to enable collaboration and prevent conflicts. A common setup uses AWS S3 + DynamoDB:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "wordpress/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Useful state commands

List all resources currently tracked:

```bash
terraform state list
```

Inspect a specific resource:

```bash
terraform state show aws_instance.wordpress-tf-instance
```

Remove a resource from state without destroying it (use with care):

```bash
terraform state rm <resource_address>
```

---

## Tips & Best Practices

**Use `.gitignore` for sensitive files**

Add these to your `.gitignore` to avoid committing state or credentials:

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
tfplan
```

**Separate variables from configuration**

Move hardcoded values into `variables.tf`:

```hcl
variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "vockey"
}
```

Then reference with `var.key_name` in `main.tf`.

**Use `terraform plan` before every apply**

Always review the plan output, especially the summary line at the bottom:

```
Plan: xx to add, 0 to change, 0 to destroy.
```

Any unexpected destroys or changes should be investigated before proceeding.

**Tag all resources**

Tags make cost tracking and resource identification much easier on AWS. Add a consistent tag block to every resource:

```hcl
tags = {
  Project     = "wordpress-tf"
  Environment = "dev"
  ManagedBy   = "terraform"
}
```
