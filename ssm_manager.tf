#we need to get some Linux AMI ID using SSM Parameter end point in us-east-1
#https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html

data "aws_ssm_parameter" "linuxAMI-us-east-1" {
  provider = aws.region-common
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAMI-us-west-2" {
  provider = aws.region-worker
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}