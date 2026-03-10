import boto3
from config import REGION, PROJECT_NAME

ec2 = boto3.client("ec2", region_name=REGION)


def create_and_attach_igw(vpc_id):
    response = ec2.create_internet_gateway()
    igw_id = response["InternetGateway"]["InternetGatewayId"]

    ec2.attach_internet_gateway(InternetGatewayId=igw_id, VpcId=vpc_id)

    ec2.create_tags(
        Resources=[igw_id], Tags=[{"Key": "Name", "Value": f"{PROJECT_NAME}-igw"}]
    )

    print("Created and attached IGW:", igw_id)
    return igw_id
