#ACM configuration for https certificate
resource "aws_acm_certificate" "jenkins-lb-https" {
  domain_name = join(".",["jenkins", data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags = {
    Name = "Jenkins-ACM"
  }
}

#Validation