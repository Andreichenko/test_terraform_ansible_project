#Create SG for LB, only for TCP/80,443 and outband access
resource "aws_security_group" "elb-sg" {
  provider = aws.region-common
  name = "ELB-SG"
  description = "Allow 443 and traffic to jenkins sg"
  vpc_id = aws_vpc.vpc_common.id

  dynamic "ingress" {
    for_each = ["443","80"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      description = "Allow 80,443 from anywhere for redirection"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags    = {
    Name                = "Common ELB SG for jenkins"
    Owner               = "Aleksandr Andreichenko"
    Environmet          = "Dev-Test"
    Region              = "us-east-1"
  }
}

#Create SG for allowing TCP/8080 from all and tcp/22 from some ip in us-east-1
