# WordPress on AWS - Terraform Deployment

A fully automated AWS infrastructure deployment for a working WordPress site using Terraform. The infrastructure is defined across dedicated `.tf` files per resource type, with WordPress installed and configured automatically on launch via a user data script.

> New to Terraform? See [TERRAFORM_GUIDE.md](../Terraform_Guide/TERRAFORM_GUIDE.md) for installation, credentials setup, and command reference.

---

## Architecture Overview

```
Internet
    |
    v
Internet Gateway (wordpress-igw)
    |
    v
VPC (wordpress-vpc)
    |
    +-- Public Subnet
            |
            +-- Public Route Table ──► IGW
            |
            +-- Security Group ──► HTTP (80), SSH (22), MySQL (3306)
            |
            +-- EC2: wordpress-tf-instance (WordPress + MariaDB)
            |
            +-- EC2: bastion-tf-instance (Bastion Host)
```

> The Bastion Host currently shares the same public subnet and security group as the WordPress instance. A dedicated private subnet and a separate security group is planned as a future improvement.

---

## What Gets Deployed

| Resource | Details |
|---|---|
| VPC | Custom CIDR block with DNS enabled |
| Internet Gateway | Attached to VPC for public internet access |
| Public Subnet | Hosts both EC2 instances |
| Route Table | Routes outbound traffic to the Internet Gateway |
| Security Group | Allows HTTP, SSH, and MySQL inbound traffic |
| EC2: WordPress Instance | Amazon Linux 2023, `t3.small`, WordPress pre-installed via user data |
| EC2: Bastion Host | Amazon Linux 2023, `t3.small`, used as a jump host for SSH access |

---

## WordPress Setup

WordPress is installed and configured automatically at instance launch using the `scripts/userdata.sh` script. No manual setup is required after `terraform apply` completes.

### What the script does

**1. System update and package installation**

```bash
dnf update -y
dnf install -y httpd mariadb114-server.x86_64 php php-mysqlnd wget tar
```

Installs Apache (`httpd`), MariaDB, PHP, and the PHP MySQL driver — everything WordPress needs to run.

**2. Start and enable services**

```bash
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb
```

Starts Apache and MariaDB and enables them to restart automatically on reboot.

**3. Database setup**

```bash
mysql -e "CREATE DATABASE wordpress;"
mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
```

Creates the WordPress database and a dedicated database user with full privileges.

**4. WordPress download and installation**

```bash
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
```

Downloads the latest WordPress release directly from wordpress.org, extracts it, and places the files into the Apache web root.

**5. File permissions**

```bash
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
```

Sets correct ownership and permissions so Apache can serve the WordPress files.

> ⚠️ **Note:** The database password in `userdata.sh` is set to `password` for lab purposes. In production, use AWS Secrets Manager or SSM Parameter Store to manage credentials securely.

---

## Project Structure

```
.
├── scripts/
│   └── userdata.sh               # WordPress bootstrap script
├── terraformConfiguration.tf     # Terraform and provider configuration
├── provider.tf                   # AWS provider settings
├── vpc.tf                        # VPC resource
├── internetGateway.tf            # Internet Gateway and VPC attachment
├── subnets.tf                    # Public subnet
├── routeTable.tf                 # Route table and subnet association
├── securityGroup.tf              # Security group and ingress/egress rules
├── ec2.tf                        # EC2 instance with user data reference
├── locals.tf                     # Common tags shared across all resources
├── variables.tf                  # Input variable declarations
├── outputs.tf                    # Output values after apply
└── .gitignore                    # Excludes state files and sensitive data
```

---

## File Breakdown

| File | Purpose |
|---|---|
| `terraformConfiguration.tf` | Terraform version and required provider block |
| `provider.tf` | AWS provider and region configuration |
| `vpc.tf` | VPC with CIDR block and DNS settings |
| `internetGateway.tf` | Internet Gateway and attachment to VPC |
| `subnets.tf` | Public subnet definition |
| `routeTable.tf` | Route table with IGW route and subnet association |
| `securityGroup.tf` | Security group with HTTP, SSH, and MySQL rules |
| `ec2.tf` | WordPress EC2 instance with user data reference, and Bastion Host instance |
| `locals.tf` | Shared tags applied to all resources via `merge()` |
| `variables.tf` | Input variables for region, instance type, and key name |
| `outputs.tf` | Prints EC2 public IP and instance ID after apply |

---

## Common Tags via Locals

All resources share a common set of tags defined once in `locals.tf` and merged at the resource level:

```hcl
locals {
  common_tags = {
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

Each resource merges these with its own `Name` tag:

```hcl
tags = merge(local.common_tags, {
  Name = "wordpress-vpc"
})
```

---

## Security Group Rules

| Direction | Protocol | Port | Source |
|---|---|---|---|
| Inbound | TCP | 22 (SSH) | `0.0.0.0/0` |
| Inbound | TCP | 80 (HTTP) | `0.0.0.0/0` |
| Inbound | TCP | 3306 (MySQL) | `0.0.0.0/0` |
| Outbound | All | All | `0.0.0.0/0` |

> ⚠️ **Note:** All inbound ports are open to `0.0.0.0/0` for lab purposes. In production, restrict SSH to your own IP and scope MySQL to the VPC CIDR only.

---

## Prerequisites

- An AWS account with programmatic access
- A key pair available in your target AWS region (update `key_name` in `variables.tf`)
- Terraform installed — see [TERRAFORM_GUIDE.md](../Terraform_Guide/TERRAFORM_GUIDE.md)

---

## Quick Start

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

terraform init
terraform plan
terraform apply
```

After a successful apply, the EC2 public IP is printed in the terminal. Open it in a browser to complete the WordPress setup wizard.

To tear everything down:

```bash
terraform destroy
```

---

## WordPress Setup Wizard

After opening the EC2 public IP in a browser, WordPress will display a database configuration screen. Since the database was already created automatically by `userdata.sh`, enter the following values exactly as shown:

| Field | Value |
|---|---|
| Database Name | `wordpress` |
| Username | `wordpressuser` |
| Password | `password` |
| Database Host | `localhost` |
| Table Prefix | `wp_` |

> The Database Host field may appear empty by default. Make sure to enter `localhost` since MariaDB is running on the same EC2 instance as WordPress.

After clicking Submit, WordPress will verify the database connection and proceed to the site information page where you set:

- Site title
- Admin username
- Admin password
- Admin email address

Once completed, your WordPress site is live and accessible via the EC2 public IP.

---

## Outputs

| Output | Description |
|---|---|
| `wordpress_instance_public_ip` | Public IP of the WordPress EC2 instance |
| `wordpress_instance_id` | WordPress EC2 instance ID |
| `bastion_instance_public_ip` | Public IP of the Bastion Host |
| `bastion_instance_id` | Bastion Host EC2 instance ID |

---

## Potential Improvements

- Store the MariaDB password in AWS Secrets Manager instead of plaintext in the script
- Add an RDS instance to separate the database from the web server
- Add an Application Load Balancer and Auto Scaling Group for high availability
- Use S3 and DynamoDB as a remote backend for Terraform state management
- Restrict SSH ingress to a specific IP address
- Move the Bastion Host to a dedicated private subnet with its own security group scoped to SSH only