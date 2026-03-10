from config import VPC_CIDR, PUBLIC_SUBNET_CIDR, AZ
from network.vpc import create_vpc
from network.internet_gateway import create_and_attach_igw
from network.subnet import create_public_subnet
from network.route_table import create_public_route_table
from network.security_group import create_security_group
from compute.ec2_instance import (
    create_ec2_instance,
    wait_for_instance,
    get_instance_public_ip,
)


def main():
    vpc_id = create_vpc(VPC_CIDR)
    igw_id = create_and_attach_igw(vpc_id)
    subnet_id = create_public_subnet(vpc_id, PUBLIC_SUBNET_CIDR, AZ)
    create_public_route_table(vpc_id, igw_id, subnet_id)
    sg_id = create_security_group(vpc_id)

    instance_id = create_ec2_instance(subnet_id, sg_id)
    wait_for_instance(instance_id)
    public_ip = get_instance_public_ip(instance_id)

    print("\nSetup completed successfully")
    print("VPC ID:", vpc_id)
    print("IGW ID:", igw_id)
    print("Subnet ID:", subnet_id)
    print("Security Group ID:", sg_id)
    print("Instance ID:", instance_id)
    print("Public IP:", public_ip)


if __name__ == "__main__":
    main()
