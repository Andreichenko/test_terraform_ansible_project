#Create DNS configuration
resource "aws_route53_zone" "dns_name" {
  provider = aws.region-common
  name = var.dnsname
}

#create record in hosted zone for acm certificate domain verification
resource "aws_route53_record" "cert_validation" {
  provider = aws.region-common
  name = aws_acm_certificate.jenkins-lb-https.domain_validation_options.resource_record_name
  type = aws_acm_certificate.jenkins-lb-https.domain_validation_options.resource_record_type
  records = [aws_acm_certificate.jenkins-lb-https.domain_validation_options.resource_record_value]
  ttl = 60
  zone_id = aws_route53_zone.dns_name.zone_id
}

#Create alias record towards ALB from route53
resource "aws_route53_record" "jenkins" {
  provider = aws.region-common
  name     = join(".", ["jenkins", aws_route53_zone.dns_name.name])
  type = "A"
  zone_id = aws_route53_zone.dns_name.zone_id
  alias {
    evaluate_target_health = true
    name = aws_lb.application_load_balancer.dns_name
    zone_id = aws_lb.application_load_balancer.zone_id
  }
}