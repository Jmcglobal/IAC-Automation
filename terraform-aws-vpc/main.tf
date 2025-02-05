## PRovider block
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">=5.0.0"
    }
  }
}

provider "aws" {
    region = "us-east-2"
}

## VPC resource

resource "aws_vpc" "my_vpc" {
    cidr_block = "192.168.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true

    tags = {
        Name = "Terraform VPC"
    }
}

## Create Subnet | 

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidr_value)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnet_cidr_value, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }

  depends_on = [ aws_vpc.my_vpc ]
}

resource "aws_subnet" "public_Subnet" {
  count = length(var.public_subnets_cidr_value)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnets_cidr_value, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index +1}"
  }

  depends_on = [ aws_vpc.my_vpc ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "VPC IG"
  }
}

## Create a elastic IP for nat gateway
# resource "aws_eip" "nat_eip" {
#   domain = "vpc"

#   tags = {
#     Name = "Nat EIP"
#   }
# }

# Create Two Elastic IP
resource "aws_eip" "double_eip" {
  count = 2
  domain = "vpc"

  tags = {
    Name = "EIP-${count.index +1}"
  }
}

## AWS Nat gateway in a single public subnets
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id = aws_subnet.public_Subnet[0].id

#   tags = {
#     Name = "Nate GW"
#   }

#   depends_on = [ aws_eip.nat_eip ]
# }

## Create Two Nat Gateway using the Two EIP
resource "aws_nat_gateway" "double_nat" {
  count = 2
  allocation_id = aws_eip.double_eip[count.index].id
  subnet_id = aws_subnet.public_Subnet[count.index].id

  tags = {
    Name = "Nat_Gw-${count.index +1}"
  }
}

## Create private RT
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private RT"
  }
}

## Create Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Public RT"
  }
}

## Create a route on public RT to internet_gateway
resource "aws_route" "route_to_internet_gateway" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

## Associate Public Subnets to Public RT
resource "aws_route_table_association" "public_subnets" {
  route_table_id = aws_route_table.public_rt.id
  count = length(var.public_subnets_cidr_value)
  subnet_id = aws_subnet.public_Subnet[count.index].id
}

## Create a route on private RT to nat gateway
resource "aws_route" "nat_gatway" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.double_nat[0].id

  depends_on = [ aws_nat_gateway.double_nat ]
}

## Associate Private Subnets to Private RT
resource "aws_route_table_association" "private_subnet" {
  count = length(var.private_subnet_cidr_value)
  route_table_id = aws_route_table.private_rt.id
  subnet_id = aws_subnet.private_subnets[count.index].id

  depends_on = [ aws_subnet.private_subnets, aws_route.nat_gatway ]
}

## Define Security group for SSH and HTTPS
resource "aws_security_group" "security_ec2" {
  name = "EC2_SSH_HTTPS"
  description = "Allow SSH and HTTPS Traffic"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.0.0.10/32"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "EC2_SSH_HTTPS_SG"
  }
}

## Define Security Group for RDS
resource "aws_security_group" "security_rds" {
  name = "RDS_SG"
  description = "Allow Inbound connection on port 5432"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [ "10.0.0.10/32" ]

  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [ aws_security_group.security_ec2.id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "ECS_SSH_HTTPS"
  }
}