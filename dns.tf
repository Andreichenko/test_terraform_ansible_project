#Create DNS configuration
data "aws_route53_zone" "dns" {
  provider = aws.region-common
  name = var.DNSname
}

#create record in hosted zone for acm certificate domain verification
resource "aws_route53_record" "cert-validation" {
  provider = aws.region-common
  for_each = {
  for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options : val.domain_name => {
    name   = val.resource_record_name
    record = val.resource_record_value
    type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.name

}

#Create alias record towards ALB from route53
resource "aws_route53_record" "jenkins" {
  provider = aws.region-common
  zone_id = data.aws_route53_zone.dns.zone_id
  name     = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  type = "A"
  alias {
    evaluate_target_health = true
    name = aws_lb.application-load-balancer.dns_name
    zone_id = aws_lb.application-load-balancer.zone_id
  }
}