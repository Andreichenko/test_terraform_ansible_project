variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_profile" {}

data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}