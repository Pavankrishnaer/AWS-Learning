import boto3
from config import REGION, PROJECT_NAME

ec2 = boto3.client("ec2", region_name=REGION)


def create_public_route_table(vpc_id, igw_id, subnet_id):
    response = ec2.create_route_table(VpcId=vpc_id)
    route_table_id = response["RouteTable"]["RouteTableId"]

    ec2.create_route(
        RouteTableId=route_table_id, DestinationCidrBlock="0.0.0.0/0", GatewayId=igw_id
    )

    ec2.associate_route_table(RouteTableId=route_table_id, SubnetId=subnet_id)

    ec2.create_tags(
        Resources=[route_table_id],
        Tags=[{"Key": "Name", "Value": f"{PROJECT_NAME}-public-rt"}],
    )

    print("Created Public Route Table:", route_table_id)
    return route_table_id
