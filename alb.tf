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