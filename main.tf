provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#IAM settings

#S3 access

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
}

#VPC

resource "aws_vpc" "common_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags{
    Name = "common_vpc"
  }
}

# Gateway

resource "aws_internet_gateway" "common_internet_gateway" {
  vpc_id = aws_vpc.common_vpc.id

  tags{
    Name = "common_internet_gateway"
  }
}

#Route Tables

resource "aws_route_table" "common_route_table" {
  vpc_id = aws_vpc.common_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.common_internet_gateway.id}"
  }

  tags = {
    Name = "common_route_public"
  }
}

resource "aws_default_route_table" "common_private_route_table" {
  default_route_table_id = "${aws_vpc.common_vpc.default_route_table_id}"

  tags = {
    Name = "common_private_route"
  }
}
