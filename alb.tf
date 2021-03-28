#create ALB for jenkins application
resource "aws_alb" "application_load_balancer" {
  provider = aws.region-common
  name = "jenkins-application-load-balancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.elb-sg.id]
  subnets = [aws_subnet.common_subnet_primary, aws_subnet.common_subnet_secondary]
  tags = {
    Name = "Jenkins_ALB"
  }
}

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
    path = "/"
    port = var.webserver-port
    protocol = "HTTP"
    matcher = "200-299"
  }
  tags = {
    Name = "jenkins_target_group"
  }
}