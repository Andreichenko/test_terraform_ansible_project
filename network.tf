# Creating VPC for us-east-1
resource "aws_vpc" "vpc_common" {
  provider              = aws.region-common
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags    = {
    Name                = "common-vpc-jenkins"
    Owner               = "Aleksandr Andreichenko"
    Environment         = "Dev-Test"
    Region              = "us-east-1"
  }
}

#Creating VPC for us-west-2
resource "aws_vpc" "vpc_common_oregon" {
  provider              = aws.region-worker
  cidr_block            = "192.168.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags    = {
    Name                = "worker-vpc-jenkins"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-west-2"
  }
}


#Create Internet Gateway in us-east-1
resource "aws_internet_gateway" "internet-gateway-common" {
  provider              = aws.region-common
  vpc_id                = aws_vpc.vpc_common.id
  tags    = {
    Name                = "Common IGW"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-east-1"
  }
}
#Create Internet Gateway in us-west-2
resource "aws_internet_gateway" "internet-gateway-worker" {
  provider              = aws.region-worker
  vpc_id                = aws_vpc.vpc_common_oregon.id
  tags    = {
    Name                = "Worker IGW"
    Region              = "us-west-2"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
  }
}

#Get all available AZ's in VPC for common
data "aws_availability_zones" "azs" {
  provider = aws.region-common
  state = "available"
}

#Create subnet for common VPC
resource "aws_subnet" "common_subnet_primary" {
  provider = aws.region-common
  cidr_block = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id = aws_vpc.vpc_common.id
  tags    = {
    Name                = "Common subnet primary"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-east-1"
  }
}

resource "aws_subnet" "common_subnet_secondary" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc_common.id
  provider = aws.region-common
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  tags    = {
    Name                = "Common subnet secondary"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-east-1"
  }
}

#Create worker subnet for us-west-2
resource "aws_subnet" "worker_subnet" {
  provider = aws.region-worker
  cidr_block = "192.168.1.0/24"
  vpc_id = aws_vpc.vpc_common_oregon.id
  tags    = {
    Name                = "Worker subnet"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-west-2"
  }
}

#Create and Initiate peering connection request from us-east-1
resource "aws_vpc_peering_connection" "east-west" {
  peer_vpc_id = aws_vpc.vpc_common_oregon.id
  vpc_id = aws_vpc.vpc_common.id
  provider = aws.region-common
  peer_region = var.region-worker
}

#Accept VPC peering request in west to east
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
 provider = aws.region-worker
  auto_accept = true
  vpc_peering_connection_id = aws_vpc_peering_connection.east-west.id
}

#Create root table in east
resource "aws_route_table" "internet_route" {
  provider = aws.region-common
  vpc_id = aws_vpc.vpc_common.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-worker.id
  }
  route {
    cidr_block = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.east-west.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Common-Regionr-Route-table"
  }
}

#Owerwrite default route table of VPC common with our route table entries
resource "aws_main_route_table_association" "set-common-worker-route-table-associate" {
  route_table_id = aws_route_table.internet_route.id
  vpc_id = aws_vpc.vpc_common.id
  provider = aws.region-common
}

#Create route table in west
resource "aws_route_table" "internet_route_oregon" {
  vpc_id = aws_vpc.vpc_common_oregon.id
  provider = aws.region-worker
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-worker.id
  }
  route {
    cidr_block = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.east-west.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "worker-region-route-table"
  }
}
