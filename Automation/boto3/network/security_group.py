import boto3
from config import REGION, PROJECT_NAME, SSH_CIDR

ec2 = boto3.client("ec2", region_name=REGION)


def create_security_group(vpc_id):
    response = ec2.create_security_group(
        GroupName=f"{PROJECT_NAME}-public-sg",
        Description="Allow SSH for lab practice",
        VpcId=vpc_id,
    )
    sg_id = response["GroupId"]

    ec2.authorize_security_group_ingress(
        GroupId=sg_id,
        IpPermissions=[
            {
                "IpProtocol": "tcp",
                "FromPort": 22,
                "ToPort": 22,
                "IpRanges": [
                    {
                        "CidrIp": SSH_CIDR,
                        "Description": "Allow SSH from anywhere for lab",
                    }
                ],
            }
        ],
    )

    print("Created Security Group:", sg_id)
    return sg_id
