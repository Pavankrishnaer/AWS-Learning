# AWS Infrastructure Automation with Python (Boto3)

This project demonstrates how to automate AWS infrastructure creation using **Python and Boto3**.

The goal is to practice **Infrastructure Automation concepts** by programmatically creating a public EC2 environment along with the required networking components.

The infrastructure is built using a **modular Python design**, where each AWS resource is managed in a separate module.

---

# Architecture Overview

The automation script creates the following AWS infrastructure:

```text
                    Internet
                       |
                       |
                +----------------+
                | Internet Gateway |
                +----------------+
                       |
                       |
                +----------------+
                |   Route Table   |
                | 0.0.0.0/0 -> IGW|
                +----------------+
                       |
                       |
        +--------------------------------------+
        |                VPC                   |
        |            10.0.0.0/16               |
        |                                      |
        |   +------------------------------+   |
        |   |      Public Subnet           |   |
        |   |        10.0.1.0/24           |   |
        |   |                              |   |
        |   |   +----------------------+   |   |
        |   |   |   Security Group     |   |   |
        |   |   |   Allow SSH : 22     |   |   |
        |   |   |   Source: 0.0.0.0/0  |   |   |
        |   |   +----------------------+   |   |
        |   |                              |   |
        |   |   +----------------------+   |   |
        |   |   |      EC2 Instance     |   |   |
        |   |   |       t3.micro        |   |   |
        |   |   |    Amazon Linux       |   |   |
        |   |   +----------------------+   |   |
        |   +------------------------------+   |
        +--------------------------------------+
```

The EC2 instance receives a **public IP address** and can be accessed using SSH.

---

# Project Structure

```text
Automation/
│
├── config.py
├── main.py
│
├── network/
│   ├── vpc.py
│   ├── subnet.py
│   ├── internet_gateway.py
│   ├── route_table.py
│   └── security_group.py
│
├── compute/
│   └── ec2_instance.py
```

### File Description

| File        | Purpose                                                                                   |
| ----------- | ----------------------------------------------------------------------------------------- |
| `config.py` | Stores configuration values such as region, CIDR blocks, AMI ID, and key pair             |
| `main.py`   | Entry point that orchestrates the infrastructure creation                                 |
| `network/`  | Contains networking components such as VPC, subnet, IGW, route tables and security groups |
| `compute/`  | Contains EC2 instance provisioning logic                                                  |

---

# Technologies Used

* Python
* Boto3 (AWS SDK for Python)
* AWS EC2
* AWS VPC
* AWS CLI
* SSH

---

# Prerequisites

Before running the project, ensure you have:

* Python **3.9 or later**
* AWS Account or AWS Sandbox
* AWS CLI installed
* An EC2 Key Pair (for SSH access)

---

# Install Dependencies

Create a virtual environment:

```bash
python3 -m venv boto3-env
source boto3-env/bin/activate
```

Install the required library:

```bash
pip install boto3
```

---

# Configure AWS Credentials (AWS Sandbox / StartLab)

If you are using an **AWS Sandbox environment** (for example AWS Academy Lab):

### Step 1

Click **Start Lab**

### Step 2

Open **AWS Details**

You will see credentials similar to:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_SESSION_TOKEN

### Step 3

Create the credentials file:

```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

Paste the credentials like this:

```text
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
aws_session_token = YOUR_SESSION_TOKEN
```

Save the file.

Boto3 will automatically use these credentials.

---

# Configuration

Edit the `config.py` file if necessary.

Example configuration:

```python
REGION = "us-west-2"
AMI_ID = "ami-xxxxxxxx"
INSTANCE_TYPE = "t3.micro"
KEY_NAME = "vockey"

VPC_CIDR = "10.0.0.0/16"
PUBLIC_SUBNET_CIDR = "10.0.1.0/24"
```

---

# Running the Automation

From the project root directory:

```bash
python main.py
```

The script will automatically:

1. Create a VPC
2. Create an Internet Gateway
3. Create a Public Subnet
4. Create a Route Table
5. Associate the subnet with the route table
6. Create a Security Group
7. Launch an EC2 instance
8. Retrieve the Public IP address

---

# Example Output

```text
Connected to AWS EC2
Created VPC: vpc-123abc
Created and attached IGW: igw-123abc
Created Public Subnet: subnet-123abc
Created Public Route Table: rtb-123abc
Created Security Group: sg-123abc
Created EC2 Instance: i-123abc
Instance is now running
Instance Public IP: 54.xxx.xxx.xxx
Setup completed successfully
```

---

# Connect to the EC2 Instance

After the instance is created:

```bash
ssh -i your-key.pem ec2-user@PUBLIC_IP
```

Example:

```bash
ssh -i vockey.pem ec2-user@54.xxx.xxx.xxx
```

---

# Important Security Note

For learning purposes, the security group allows SSH access from anywhere:

```text
0.0.0.0/0
```

This configuration should **never be used in production environments**.
In real deployments, restrict access to specific IP ranges.

---

# Learning Objectives

This project demonstrates:

* AWS infrastructure automation using Python
* Using the **Boto3 EC2 API**
* Creating AWS networking components programmatically
* Modular Python project design
* Automating EC2 provisioning

---

# Author

Created as part of personal learning while transitioning into **AWS / DevOps Engineering**.
