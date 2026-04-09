# CloudFormation Guide

A standalone reference for understanding AWS CloudFormation, covering how templates are structured, key concepts, and the CLI commands to deploy and manage stacks. Everything you need to go from a YAML file to running infrastructure.

---

## Table of Contents

- [What is CloudFormation?](#what-is-cloudformation)
- [CloudFormation vs Terraform](#cloudformation-vs-terraform)
- [Template Structure](#template-structure)
- [Key Concepts](#key-concepts)
- [CLI Commands Reference](#cli-commands-reference)
- [Deploying via AWS Console](#deploying-via-aws-console)
- [Stack Lifecycle](#stack-lifecycle)
- [Tips & Best Practices](#tips--best-practices)

---

## What is CloudFormation?

AWS CloudFormation is an **Infrastructure as Code (IaC)** service that lets you define and provision AWS resources using YAML or JSON templates. Instead of manually clicking through the AWS Console, you describe the desired state of your infrastructure in a template file and CloudFormation handles the creation, updating, and deletion of resources in the correct order.

Key benefits:
- **Repeatable:** Deploy the same infrastructure across multiple environments (dev, staging, prod) with zero manual steps
- **Version controlled:** Store templates in Git just like application code
- **Automatic rollback:** If a stack creation fails, CloudFormation rolls back all changes automatically
- **Dependency management:** CloudFormation figures out the correct order to create resources based on their references

---

## CloudFormation vs Terraform

| Feature | CloudFormation | Terraform |
|---|---|---|
| Provider | AWS only | Multi-cloud (AWS, Azure, GCP, etc.) |
| Language | YAML or JSON | HCL (HashiCorp Configuration Language) |
| State management | Managed by AWS automatically | Requires a state file (local or remote) |
| Rollback | Automatic on failure | Manual intervention needed |
| Pricing | Free (pay only for resources) | Free (open source) |
| AWS integration | Native, first-party | Via AWS provider plugin |

---

## Template Structure

A CloudFormation template is a YAML (or JSON) file with the following top-level sections:

```yaml
AWSTemplateFormatVersion: "2010-09-09"   # Always this value for YAML templates
Description: A brief description of the template

Parameters:     # Optional - input values that can be passed at deploy time
  ...

Mappings:       # Optional - lookup tables (e.g. AMI IDs per region)
  ...

Conditions:     # Optional - logic to conditionally create resources
  ...

Resources:      # Required - the AWS resources to create
  ...

Outputs:        # Optional - values to display after stack creation
  ...
```

Only `Resources` is required. All other sections are optional.

---

### Parameters

Parameters allow you to pass dynamic values into your template at deploy time without modifying the template itself.

```yaml
Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    Description: EC2 instance type
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
```

Reference a parameter in your template using `!Ref`:

```yaml
InstanceType: !Ref InstanceType
```

**SSM Parameter Store integration:** You can also pull values directly from AWS SSM:

```yaml
Parameters:
  LatestAmiId:
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64
```

This fetches the latest Amazon Linux 2023 AMI automatically, with no hardcoded AMI IDs needed.

---

### Resources

The `Resources` section is the core of every template. Each resource has a **logical ID**, a **Type**, and **Properties**:

```yaml
Resources:
  MyVPC:                          # Logical ID - used to reference this resource elsewhere
    Type: AWS::EC2::VPC           # AWS resource type
    Properties:
      CidrBlock: 10.0.0.0/16
      Tags:
        - Key: Name
          Value: my-vpc
```

---

### Outputs

Outputs display useful values after a stack is created, such as IDs or endpoints.

```yaml
Outputs:
  VPCId:
    Description: The ID of the VPC
    Value: !Ref MyVPC
```

---

## Key Concepts

### Intrinsic Functions

CloudFormation provides built-in functions to dynamically resolve values inside templates.

| Function | Description | Example |
|---|---|---|
| `!Ref` | References a resource or parameter | `!Ref MyVPC` |
| `!GetAtt` | Gets an attribute of a resource | `!GetAtt MyInstance.PublicIp` |
| `!Sub` | String substitution | `!Sub "Stack is ${AWS::StackName}"` |
| `!Select` | Selects an item from a list | `!Select [0, !GetAZs ""]` |
| `!GetAZs` | Returns a list of AZs in a region | `!GetAZs ""` |
| `!Join` | Joins values with a delimiter | `!Join [",", [a, b, c]]` |
| `!If` | Conditional value | `!If [IsProd, t3.large, t3.micro]` |

### DependsOn

By default, CloudFormation infers the creation order from resource references. Use `DependsOn` when a resource must wait for another to be fully ready, even if there is no direct reference between them:

```yaml
LabEC2Instance:
  Type: AWS::EC2::Instance
  DependsOn: LabVPCGatewayAttachment
  Properties:
    ...
```

### Stack

A **stack** is a single unit of deployment. It is the collection of all resources defined in one template. You create, update, and delete resources by operating on the stack, not on individual resources.

### Change Sets

Before updating a live stack, you can create a **Change Set** to preview exactly what will be added, modified, or deleted, without applying the changes yet. This is the CloudFormation equivalent of `terraform plan`.

```bash
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --template-body file://template.yaml
```

---

## CLI Commands Reference

### Deploy a new stack

```bash
aws cloudformation create-stack \
  --stack-name <stack-name> \
  --template-body file://template.yaml
```

### Deploy with parameters

```bash
aws cloudformation create-stack \
  --stack-name <stack-name> \
  --template-body file://template.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.small
```

### Check stack status

```bash
aws cloudformation describe-stacks \
  --stack-name <stack-name> \
  --query "Stacks[0].StackStatus"
```

### List all stacks

```bash
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```

### View stack events (useful for debugging failures)

```bash
aws cloudformation describe-stack-events \
  --stack-name <stack-name>
```

### View stack outputs

```bash
aws cloudformation describe-stacks \
  --stack-name <stack-name> \
  --query "Stacks[0].Outputs"
```

### Update an existing stack

```bash
aws cloudformation update-stack \
  --stack-name <stack-name> \
  --template-body file://template.yaml
```

### Validate a template before deploying

```bash
aws cloudformation validate-template \
  --template-body file://template.yaml
```

### Delete a stack

```bash
aws cloudformation delete-stack \
  --stack-name <stack-name>
```

### Wait until stack creation is complete

```bash
aws cloudformation wait stack-create-complete \
  --stack-name <stack-name>
```

---

### Full Commands Reference Table

| Command | Description |
|---|---|
| `create-stack` | Deploy a new stack from a template |
| `update-stack` | Update an existing stack |
| `delete-stack` | Delete a stack and all its resources |
| `describe-stacks` | Get stack details, status, and outputs |
| `describe-stack-events` | View events (essential for debugging) |
| `list-stacks` | List all stacks filtered by status |
| `validate-template` | Check template syntax before deploying |
| `create-change-set` | Preview changes before updating a stack |
| `execute-change-set` | Apply a previously created change set |
| `wait stack-create-complete` | Block until stack creation finishes |
| `wait stack-delete-complete` | Block until stack deletion finishes |

---

## Deploying via AWS Console

1. Go to **AWS Console → CloudFormation → Create Stack → Choose an existing template**
2. Choose **Upload a template file** and select your `.yaml` file
3. Click **Next** and enter a **Stack name**
4. Fill in any **Parameters** if prompted
5. Click through the options and hit **Create Stack**
6. Monitor progress under the **Events** tab. Each resource shows its creation status in real time
7. Once complete, check the **Outputs** tab for resource IDs and values

---

## Stack Lifecycle

```
create-stack
     │
     ▼
CREATE_IN_PROGRESS
     │
     ├── success ──► CREATE_COMPLETE
     │
     └── failure ──► ROLLBACK_IN_PROGRESS ──► ROLLBACK_COMPLETE

update-stack
     │
     ▼
UPDATE_IN_PROGRESS
     │
     ├── success ──► UPDATE_COMPLETE
     │
     └── failure ──► UPDATE_ROLLBACK_COMPLETE

delete-stack
     │
     ▼
DELETE_IN_PROGRESS
     │
     └── success ──► (stack removed)
```

---

## Tips & Best Practices

**Always validate before deploying**

Catch syntax errors before they reach AWS:

```bash
aws cloudformation validate-template \
  --template-body file://template.yaml
```

**Use Change Sets before updating live stacks**

Never run `update-stack` on a production stack without previewing the changes first with a Change Set.

**Use SSM Parameter Store for AMI IDs**

Never hardcode AMI IDs. They are region-specific and go out of date. Use:

```yaml
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
Default: /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64
```

**Use DependsOn for non-obvious dependencies**

If a resource relies on another being fully ready but doesn't directly reference it, add `DependsOn` explicitly to avoid race conditions.

**Tag every resource**

```yaml
Tags:
  - Key: Project
    Value: my-project
  - Key: Environment
    Value: dev
  - Key: ManagedBy
    Value: cloudformation
```