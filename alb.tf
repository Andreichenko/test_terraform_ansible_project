#create ALB for jenkins application
resource "aws_lb" "application_load_balancer" {
  provider = aws.region-common
  name = "jenkins-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.elb-sg.id]
  subnets = [aws_subnet.common_subnet_primary.id, aws_subnet.common_subnet_secondary.id]
  tags = {
    Name = "Jenkins_ALB"
  }
}
#Create target group
resource "aws_lb_target_group" "app-lb-tg" {
  provider = aws.region-common
  name = "app-lb-tg"
  port = var.webserver-port
  target_type = "instance"
  vpc_id = aws_vpc.vpc_common.id
  protocol = "HTTP"
  health_check {
    enabled = true
    interval = 10
    path = "/login"
    port = var.webserver-port
    protocol = "HTTP"
    matcher = "200-299"
  }
  tags = {
    Name = "jenkins_target_group"
  }
}

resource "aws_lb_listener" "jenkins-listener-https" {
  provider = aws.region-common
  load_balancer_arn = aws_lb.application_load_balancer.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port = 443
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.jenkins-lb-https.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_listener" "jenkins-listener-http" {
  provider = aws.region-common
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      status_code = "HTTP_301"
      protocol = "HTTPS"
    }
  }
}

resource "aws_lb_target_group_attachment" "jenkins_master-attachment" {
  provider = aws.region-common
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id = aws_instance.jenkins-master-node.id
  port = var.webserver-port
}
