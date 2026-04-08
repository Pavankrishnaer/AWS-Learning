# WordPress on AWS - Terraform Infrastructure

Automated AWS infrastructure provisioning for a WordPress deployment using Terraform. Defines a custom VPC with public/private subnets, an Internet Gateway, route tables, security groups, and an EC2 instance running Amazon Linux 2023 — all as code.

> New to Terraform? See [TERRAFORM_GUIDE.md](./TERRAFORM_GUIDE.md) for installation, credentials setup, and command reference.

---

## Architecture Overview

```
Internet
    │
    ▼
Internet Gateway (wordpress-tf-igw)
    │
    ▼
VPC: 192.168.0.0/27 (wordpress-tf-vpc)
    ├── Public Subnet: 192.168.0.0/28   ──► EC2 Instance (WordPress)
    │       └── Public Route Table ──► IGW
    │
    └── Private Subnet: 192.168.0.16/28
            └── Private Route Table (local only)
```

---

## Resources Provisioned

| Resource | Name | Details |
|---|---|---|
| VPC | `wordpress-tf-vpc` | CIDR: `192.168.0.0/27` |
| Public Subnet | `wordpress-tf-public-subnet` | `192.168.0.0/28` |
| Private Subnet | `wordpress-tf-private-subnet` | `192.168.0.16/28` |
| Internet Gateway | `wordpress-tf-igw` | Attached to VPC |
| Public Route Table | `wordpress-tf-public-route-table` | Routes `0.0.0.0/0` → IGW |
| Private Route Table | `wordpress-tf-private-route-table` | Local only |
| Security Group | `wordpress-tf-sg` | HTTP, SSH, MySQL inbound |
| EC2 Instance | `wordpress-tf-instance` | Amazon Linux 2023, `t3.small` |

---

## Security Group Rules

| Direction | Protocol | Port | Source |
|---|---|---|---|
| Inbound | TCP | 22 (SSH) | `0.0.0.0/0` |
| Inbound | TCP | 80 (HTTP) | `0.0.0.0/0` |
| Inbound | TCP | 3306 (MySQL) | `0.0.0.0/0` |
| Outbound | All | All | `0.0.0.0/0` |

> ⚠️ **Note:** SSH and MySQL ports are open to all IPs (`0.0.0.0/0`) for development convenience. Before using in production, restrict SSH to your own IP and scope MySQL to the private subnet CIDR only.

---

## Prerequisites

- An AWS account with programmatic access
- A key pair named `vockey` in your target AWS region (or update `key_name` in `variables.tf`)
- Terraform installed — see [TERRAFORM_GUIDE.md](./TERRAFORM_GUIDE.md)

---

## Quick Start

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

terraform init
terraform plan
terraform apply
```

To tear everything down:

```bash
terraform destroy
```

---

## Project Structure

```
.
├── main.tf               # Resource definitions
├── variables.tf          # Input variable declarations
├── outputs.tf            # Output value declarations
├── .gitignore            # Files excluded from version control
├── README.md             # This file
└── TERRAFORM_GUIDE.md    # Terraform install, setup & commands reference
```

---

## Provider

- **AWS Provider:** `hashicorp/aws` v6.39.0
- **AMI:** Latest Amazon Linux 2023 (`al2023-ami-2023.*-x86_64`) — resolved dynamically at apply time

---

## Potential Improvements

- Replace open MySQL ingress with a private-subnet-scoped rule
- Add a NAT Gateway to allow outbound internet from the private subnet
- Use S3 + DynamoDB as a remote backend for team state management

---

## License

MIT
