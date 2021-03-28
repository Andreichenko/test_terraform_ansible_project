#Create DNS configuration
resource "aws_route53_zone" "dns" {
  provider = aws.region-common
  name = var.dns-name
}

#create record in hosted zone for acm certificate domain verification
resource "aws_route53_record" "cert_validation" {
  provider = aws.region-common
  for_each = {
    for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options : val.domain_name => {
    name = val.resource_record_name
    record = val.resource_record_value
    type = val.resource_record_type
    }
  }
  name = each.value.name
  type = each.value.type
  records = [each.value.record]
  ttl = 60
  zone_id = data.aws_route53_zone.dns.zone_id
}

#Create alias record towards ALB from route53
resource "aws_route53_record" "jenkins" {
  provider = aws.region-common
  name     = join(".", ["jenkins", var.dns-name])
  type = "A"
  zone_id = aws_route53_zone.dns.zone_id
  alias {
    evaluate_target_health = true
    name = aws_lb.application_load_balancer.dns_name
    zone_id = aws_lb.application_load_balancer.zone_id
  }
}