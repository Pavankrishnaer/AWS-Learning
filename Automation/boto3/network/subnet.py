import boto3
from config import REGION, PROJECT_NAME

ec2 = boto3.client("ec2", region_name=REGION)


def create_public_subnet(vpc_id, cidr_block, availability_zone):
    response = ec2.create_subnet(
        VpcId=vpc_id, CidrBlock=cidr_block, AvailabilityZone=availability_zone
    )
    subnet_id = response["Subnet"]["SubnetId"]

    ec2.modify_subnet_attribute(SubnetId=subnet_id, MapPublicIpOnLaunch={"Value": True})

    ec2.create_tags(
        Resources=[subnet_id],
        Tags=[{"Key": "Name", "Value": f"{PROJECT_NAME}-public-subnet"}],
    )

    print("Created Public Subnet:", subnet_id)
    return subnet_id
