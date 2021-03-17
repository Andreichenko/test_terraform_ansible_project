variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_profile" {}

data "aws_availability_zones" "newzone" {}
variable "vpc_cidr" {}