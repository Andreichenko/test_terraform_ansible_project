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
  source = ""
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
  provider              = var.region-common
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
  provider              = var.region-worker
  vpc_id                = aws_vpc.vpc_common_oregon.id
  tags    = {
    Name                = "Worker IGW"
    Region              = "us-west-2"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
  }
}

#Get all available AZ's in VPC for common

