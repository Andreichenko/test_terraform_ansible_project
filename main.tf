provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}