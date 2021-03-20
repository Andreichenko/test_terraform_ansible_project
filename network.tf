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