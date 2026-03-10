import boto3
from config import REGION, AMI_ID, INSTANCE_TYPE, KEY_NAME, PROJECT_NAME

ec2 = boto3.client("ec2", region_name=REGION)


def create_ec2_instance(subnet_id, sg_id):
    response = ec2.run_instances(
        ImageId=AMI_ID,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
        MinCount=1,
        MaxCount=1,
        SubnetId=subnet_id,
        SecurityGroupIds=[sg_id],
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [{"Key": "Name", "Value": f"{PROJECT_NAME}-ec2"}],
            }
        ],
    )

    instance_id = response["Instances"][0]["InstanceId"]
    print("Created EC2 Instance:", instance_id)
    return instance_id


def wait_for_instance(instance_id):
    waiter = ec2.get_waiter("instance_running")
    waiter.wait(InstanceIds=[instance_id])
    print("Instance is now running")


def get_instance_public_ip(instance_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    public_ip = response["Reservations"][0]["Instances"][0].get("PublicIpAddress")
    print("Instance Public IP:", public_ip)
    return public_ip
