#Create SG for LB, only for TCP/80,443 and outband access
resource "aws_security_group" "elb-sg" {
  provider = aws.region-common
  name = "ELB-SG"
  description = "Allow 443 and traffic to jenkins sg"
  vpc_id = aws_vpc.vpc_common.id
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow 443 from anywhere"
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow 80 from anywhere for redirection"
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}