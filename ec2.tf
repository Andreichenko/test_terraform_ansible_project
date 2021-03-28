#we need to get some Linux AMI ID using SSM Parameter end point in us-east-1
#https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html

data "aws_ssm_parameter" "linuxAMI-us-east-1" {
  provider = aws.region-common
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAMI-us-west-2" {
  provider = aws.region-worker
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "common-key" {
  provider = aws.region-common
  public_key = file("~/.ssh/id_rsa.pub")
  key_name = "jenkins"
}

#create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider = aws.region-worker
  public_key = file("~/.ssh/id_rsa.pub")
  key_name = "jenkins-key-worker"
}

#create and bootstrap ec2 in us-east-1
resource "aws_instance" "jenkins-master-node" {
  provider = aws.region-common
  ami = data.aws_ssm_parameter.linuxAMI-us-east-1.value
  instance_type = var.instance_type
  key_name = aws_key_pair.common-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  subnet_id = aws_subnet.common_subnet_primary.id

  tags = {
    Name = "Jenkins-master"
  }
  depends_on = [aws_main_route_table_association.set-common-worker-route-table-associate]
}

#create and bootstrap ec2 in us-west-1
resource "aws_instance" "jenkins-worker-node" {
  provider = aws.region-worker
  count = var.workers-count
  ami = data.aws_ssm_parameter.linuxAMI-us-west-2.value
  instance_type = var.instance_type
  key_name = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-sg-oregon.id]
  subnet_id = aws_subnet.worker_subnet.id

  tags = {
    Name = join("_",["jenkins_worker", count.index + 1])
  }
  depends_on = [aws_main_route_table_association.set-worker-default-route-table-associate, aws_instance.jenkins-master-node]
}
