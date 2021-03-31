#we need to get some Linux AMI ID using SSM Parameter end point in us-east-1
#https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html

data "aws_ssm_parameter" "linuxAMI-us-east-1" {
  provider                     = aws.region-common
  name                         = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAMI-us-west-2" {
  provider                     = aws.region-worker
  name                         = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "common-key" {
  provider                     = aws.region-common
  public_key                   = file("~/.ssh/id_rsa.pub")
  key_name                     = "jenkins"
}

#create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider                     = aws.region-worker
  public_key                   = file("~/.ssh/id_rsa.pub")
  key_name                     = "jenkins-key-worker"
}

#create and bootstrap ec2 in us-east-1
resource "aws_instance" "jenkins-master-node" {
  provider                     = aws.region-common
  ami                          = data.aws_ssm_parameter.linuxAMI-us-east-1.value
  instance_type                = var.instance_type
  key_name                     = aws_key_pair.common-key.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.jenkins-sg.id]
  subnet_id                    = aws_subnet.common_subnet_primary.id

  tags = {
    Name                       = "jenkins_master"
  }
  depends_on = [aws_main_route_table_association.set-common-worker-rt-associate]

  provisioner "local-exec" {
    command                    = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-common} --instance-ids ${self.id}
ansible-playbook ansible/jenkins-master.yml -i ansible/inventory/aws_ec2.yml --extra-vars 'hosts=tag_Name_${self.tags.Name}'
EOF
  }
}

#create and bootstrap ec2 in us-west-1
resource "aws_instance" "jenkins-worker-node" {
  provider                     = aws.region-worker
  count                        = var.workers-count
  ami                          = data.aws_ssm_parameter.linuxAMI-us-west-2.value
  instance_type                = var.instance_type
  key_name                     = aws_key_pair.worker-key.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.jenkins-sg-oregon.id]
  subnet_id                    = aws_subnet.worker_subnet.id

  tags       = {
    Name                       = join("_",["jenkins_worker", count.index + 1])
  }
  depends_on = [aws_main_route_table_association.set-worker-default-rt-associate, aws_instance.jenkins-master-node]

  provisioner "local-exec" {
    command                    = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id}
ansible-playbook ansible/jenkins-worker.yml -i ansible/inventory/aws_ec2.yml --extra-vars 'hosts=tag_Name_${self.tags.Name} master_ip=${aws_instance.jenkins-master-node.private_ip}'
EOF
  }

  provisioner "remote-exec" {
    when                       = destroy
    inline                     =[
    "java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://${aws_instance.jenkins-master-node.private_ip}:8080 -auth @/home/ec2-user/jenkins_auth delete-node ${self.private_ip}"
    ]
    connection {
      type                     = "ssh"
      user                     = "ec2-user"
      private_key              = file("~/.ssh/id_rsa")
      host                     = self.public_ip
    }
  }
}
