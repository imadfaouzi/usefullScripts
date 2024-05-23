#!/bin/bash

# Usage: ./delete_vpc_resources.sh <vpc-id>
if [ -z "$1" ]; then
  echo "Usage: $0 <vpc-id>"
  exit 1
fi

VPC_ID=$1
echo "Starting deletion of resources for VPC: $VPC_ID"

# Delete NAT Gateways and EIPs
echo "Deleting NAT Gateways and associated Elastic IPs..."
NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[].NatGatewayId" --output text)
for NAT_GATEWAY_ID in $NAT_GATEWAY_IDS; do
  echo "Deleting NAT Gateway: $NAT_GATEWAY_ID"
  ALLOCATION_ID=$(aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_GATEWAY_ID --query "NatGateways[].NatGatewayAddresses[].AllocationId" --output text)
  aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GATEWAY_ID
  echo "Releasing Elastic IP: $ALLOCATION_ID"
  aws ec2 release-address --allocation-id $ALLOCATION_ID
done

# Detach and delete Internet Gateway
echo "Detaching and deleting Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text)
if [ -n "$IGW_ID" ]; then
  echo "Detaching Internet Gateway: $IGW_ID"
  aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
  echo "Deleting Internet Gateway: $IGW_ID"
  aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi

# Delete route tables (excluding the main route table)
echo "Deleting route tables..."
ROUTE_TABLE_IDS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[0].Main!=\`true\`].RouteTableId" --output text)
for ROUTE_TABLE_ID in $ROUTE_TABLE_IDS; do
  echo "Deleting Route Table: $ROUTE_TABLE_ID"
  aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_ID
done

# Delete subnets
echo "Deleting subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
for SUBNET_ID in $SUBNET_IDS; do
  echo "Deleting Subnet: $SUBNET_ID"
  aws ec2 delete-subnet --subnet-id $SUBNET_ID
done

# Delete security groups (excluding the default one)
echo "Deleting security groups..."
SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
for SG_ID in $SG_IDS; do
  echo "Deleting Security Group: $SG_ID"
  aws ec2 delete-security-group --group-id $SG_ID
done

# Delete network ACLs (excluding the default one)
echo "Deleting network ACLs..."
NACL_IDS=$(aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkAcls[?IsDefault==`false`].NetworkAclId" --output text)
for NACL_ID in $NACL_IDS; do
  echo "Deleting Network ACL: $NACL_ID"
  aws ec2 delete-network-acl --network-acl-id $NACL_ID
done

# Delete VPC endpoints
echo "Deleting VPC endpoints..."
ENDPOINT_IDS=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query "VpcEndpoints[].VpcEndpointId" --output text)
for ENDPOINT_ID in $ENDPOINT_IDS; do
  echo "Deleting VPC Endpoint: $ENDPOINT_ID"
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $ENDPOINT_ID
done

# Delete VPC peering connections
echo "Deleting VPC peering connections..."
PEERING_IDS=$(aws ec2 describe-vpc-peering-connections --filters "Name=requester-vpc-info.vpc-id,Values=$VPC_ID" --query "VpcPeeringConnections[].VpcPeeringConnectionId" --output text)
for PEERING_ID in $PEERING_IDS; do
  echo "Deleting VPC Peering Connection: $PEERING_ID"
  aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $PEERING_ID
done

# Finally, delete the VPC
echo "Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "VPC and associated resources deleted successfully."
