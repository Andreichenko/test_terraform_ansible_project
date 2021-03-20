output "aws_worker_subnet" {
  value = aws_subnet.worker_subnet.id
}

output "aws_common_subnet_primary" {
  value = aws_subnet.common_subnet_primary.id
}

output "aws_common_subnet_secondary" {
  value = aws_subnet.common_subnet_secondary.id
}

output "internet-gateway-common" {
  value = aws_internet_gateway.internet-gateway-common.id
}

output "internet-gateway-worker" {
  value = aws_internet_gateway.internet-gateway-worker.id
}

output "vpc_common" {
  value = aws_vpc.vpc_common.cidr_block
}