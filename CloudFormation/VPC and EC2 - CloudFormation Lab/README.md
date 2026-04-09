# AWS re/Start Challenge Lab: VPC and EC2 with CloudFormation

Automated AWS infrastructure provisioning using an AWS CloudFormation template. Creates a complete network environment including a VPC, Internet Gateway, private subnet, security group, and an EC2 instance, all defined as a single YAML template.

> New to CloudFormation? See [CLOUDFORMATION_GUIDE.md](../CloudFormation_Guide/CLOUDFORMATION_GUIDE.md) for template structure, concepts, and CLI commands.

---

## Architecture Overview

```
VPC: 10.0.0.0/16 (lab-vpc)
    │
    ├── Internet Gateway (lab-igw) ── attached to VPC (no route from private subnet)
    │
    └── Private Subnet: 10.0.1.0/24 (lab-private-subnet) [us-west-2a]
            │
            ├── Route Table (lab-private-route-table)
            │       └── 10.0.0.0/16 → local only (no IGW route)
            │
            ├── Security Group (lab-sg) ── SSH port 22 open
            │
            └── EC2 Instance (lab-ec2-instance) ── t3.micro, Amazon Linux 2023
```

> The Internet Gateway is attached to the VPC but the private subnet route table has no route pointing to it. This means the EC2 instance has no direct internet access, confirming the subnet is truly private.

---

## Resources Provisioned

| Resource | Name | Details |
|---|---|---|
| VPC | `lab-vpc` | CIDR: `10.0.0.0/16`, DNS enabled |
| Internet Gateway | `lab-igw` | Attached to VPC |
| Private Subnet | `lab-private-subnet` | `10.0.1.0/24`, no public IP on launch |
| Route Table | `lab-private-route-table` | Local route only |
| Security Group | `lab-sg` | SSH (port 22) inbound from `0.0.0.0/0` |
| EC2 Instance | `lab-ec2-instance` | Amazon Linux 2023, `t3.micro` |

---

## Security Group Rules

| Direction | Protocol | Port | Source |
|---|---|---|---|
| Inbound | TCP | 22 (SSH) | `0.0.0.0/0` |
| Outbound | All | All | `0.0.0.0/0` |

> ⚠️ **Note:** SSH is open to all IPs for lab purposes. In production, restrict this to your own IP address.

---

## Prerequisites

- An AWS account with permissions to create VPC, EC2, and CloudFormation resources
- AWS CLI installed and configured. See [CLOUDFORMATION_GUIDE.md](../CloudFormation_Guide/CLOUDFORMATION_GUIDE.md)

---

## Quick Start

**Via AWS Console:**
1. Go to **CloudFormation → Create Stack → With new resources**
2. Choose **Upload a template file** and upload `lab-cloudformation.yaml`
3. Enter a stack name e.g. `lab-vpc-stack`
4. Click through and hit **Create Stack**
5. Monitor progress under the **Events** tab

**Via AWS CLI:**
```bash
aws cloudformation create-stack \
  --stack-name lab-vpc-stack \
  --template-body file://lab-cloudformation.yaml
```

Check stack status:
```bash
aws cloudformation describe-stacks \
  --stack-name lab-vpc-stack \
  --query "Stacks[0].StackStatus"
```

To tear everything down:
```bash
aws cloudformation delete-stack \
  --stack-name lab-vpc-stack
```

---

## Outputs

After a successful stack creation, CloudFormation prints the following outputs:

| Output | Description |
|---|---|
| `VPCId` | ID of the created VPC |
| `PrivateSubnetId` | ID of the private subnet |
| `SecurityGroupId` | ID of the security group |
| `EC2InstanceId` | ID of the EC2 instance |

---

## Project Structure

```
AWS-Learning/
└── CloudFormation/
    ├── CloudFormation_Guide/
    │   └── CLOUDFORMATION_GUIDE.md    # CloudFormation concepts & commands reference
    └── VPC and EC2 - CloudFormation Lab/
        ├── lab-cloudformation.yaml    # CloudFormation template
        └── README.md                  # This file
```

---

## Key Design Decisions

**Dynamic AMI resolution:** Instead of hardcoding an AMI ID (which is region-specific), the template uses AWS SSM Parameter Store to fetch the latest Amazon Linux 2023 AMI automatically. This makes the template portable across any AWS region.

**DependsOn IGW attachment:** The EC2 instance explicitly depends on the Internet Gateway attachment completing first. This prevents a race condition where the instance tries to launch before the VPC is fully ready.

**Private subnet by design:** `MapPublicIpOnLaunch: false` ensures no public IP is assigned to the instance. The route table has no IGW route, confirming the subnet is truly private with local-only traffic.

---

## Potential Improvements

- Add a public subnet and NAT Gateway to allow outbound internet from the private subnet
- Add a key pair parameter to enable SSH access to the instance
- Enable CloudWatch detailed monitoring on the EC2 instance
- Add a user data script to bootstrap software on launch

---

## License

MIT
