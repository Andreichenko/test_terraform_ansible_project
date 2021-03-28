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

output "jenkins-master-node-public-ip" {
  value = aws_instance.jenkins-master-node.public_ip
}

output "jenkins-worker-node-public-ip" {
  value = {
    for instance in aws_instance.jenkins-worker-node :
        instance.id => instance.public_ip
  }
}
#ALB DNS name
output "load_balancer_dns-name" {
  value = aws_lb.application_load_balancer.dns_name
}

#route 53 DNS name
output "dns" {
  value = aws_route53_record.jenkins.fqdn
}

