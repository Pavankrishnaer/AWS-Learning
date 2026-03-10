import boto3
from config import REGION, PROJECT_NAME

ec2 = boto3.client("ec2", region_name=REGION)


def create_vpc(cidr_block):
    response = ec2.create_vpc(CidrBlock=cidr_block)
    vpc_id = response["Vpc"]["VpcId"]

    ec2.modify_vpc_attribute(VpcId=vpc_id, EnableDnsSupport={"Value": True})
    ec2.modify_vpc_attribute(VpcId=vpc_id, EnableDnsHostnames={"Value": True})

    ec2.create_tags(
        Resources=[vpc_id], Tags=[{"Key": "Name", "Value": f"{PROJECT_NAME}-vpc"}]
    )

    print("Created VPC:", vpc_id)
    return vpc_id
