#Create SG for LB, only for TCP/80,443 and outbound access
resource "aws_security_group" "elb-sg" {
  provider                 = aws.region-common
  name                     = "ELB-SG"
  description              = "Allow 443 and traffic to jenkins sg"
  vpc_id                   = aws_vpc.vpc_common.id

  dynamic "ingress" {
    for_each               = ["443","80"]
    content {
      from_port            = ingress.value
      to_port              = ingress.value
      protocol             = "tcp"
      description          = "Allow 80,443 from anywhere for redirection"
      cidr_blocks          = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port              = 0
    protocol               = "-1"
    to_port                = 0
    cidr_blocks            = ["0.0.0.0/0"]
  }
  tags    = {
    Name                   = "Common ELB SG for jenkins"
    Owner                  = "Aleksandr Andreichenko"
    Environmet             = "Dev-Test"
    Region                 = "us-east-1"
  }
}

#Create SG for allowing TCP/8080 from all and tcp/22 from some ip in us-east-1
resource "aws_security_group" "jenkins-sg" {
  provider = aws.region-common
  name = "jenkins-sg"
  description = "Allow tcp/8080 tcp/22"
  vpc_id = aws_vpc.vpc_common.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow anyone on port 8080"
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    security_groups = [aws_security_group.elb-sg.id]
  }
  ingress {
    description = "allow traffic from us-west-2"
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create SG for allowing tcp 22 from our ip us-west-2
resource "aws_security_group" "jenkins-sg-oregon" {
  provider = aws.region-worker

  name = "jenkins-sg-oregon"
  description = "Allow TCP 8080 and tcp 22"
  vpc_id = aws_vpc.vpc_common_oregon.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    description = "allow 22 port from our public ip"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    description = "allow all traffic from us-east-1"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
