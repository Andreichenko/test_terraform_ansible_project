#ACM configuration for https certificate
resource "aws_acm_certificate" "jenkins-lb-https" {
  provider = aws.region-common
  domain_name = join(".",["jenkins", data.aws_route53_zone.dns-name])
  validation_method = "DNS"
  tags = {
    Name = "Jenkins-ACM"
  }
}

#Validation acm issued certificate via route53
resource "aws_acm_certificate_validation" "cert" {
  provider = aws.region-common
  certificate_arn = aws_acm_certificate.jenkins-lb-https.arn
  for_each = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}