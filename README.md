# Jenkins master and worker solution unsing terraform and ansible

This automation is for installing and deploying Jenkins CI with a specific configuration that can be changed. The first version of the solution is now ready, which only works in AWS. It is planned to add modules for the multicloud infrastructure, which includes modules. I have prepared some diagram that will give you an understanding of the architecture.

![Untitled Diagram](https://user-images.githubusercontent.com/20015341/113284469-58884a80-92f2-11eb-8ada-dcde2904004c.png)


## Installation

### Requirments

We should install terraform, now the project supports terraform 0.12.0 and higher, also Python3 & PIP needs to be installed on all nodes, ansible and awscli via pip.
```bash
wget -c https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
yum -y install python3-pip
pip3 install ansible --user
pip3 install awscli --user 
```
jq (install via package manager) - OPTIONAL
```bash
yum -y install jq
```
This project has been tested on MacOS (Big Sur), CentOS7. The steps are general enough that with little or no customization,this might work on a range of OS's which support above requirments.

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install boto3

```bash
pip install boto3
```
### Install
To install, enter credentials with aws configure and then create an s3 bucket. This project requires an S3 backend for storing Terraform state file, therefore in the terraform block in the backend.tf file you'll need to plug in the an actual bucket name before you can run "terraform init".
Please also note that the "terraform" block does not allow usage of variables so values HAVE to be hardcoded.
```bash
aws s3api create-bucket --bucket <YOUR-BUCKET-NAME>
```
The resulting value should be written to the backend.tf file in the "bucket" value.

The regional AWS providers are defined in providers.tf Terraform configuration and backend is defined in backend.tf.

Among other things, be aware of the host zones in Route53. The best way is to test it in a test environment or re-create it. You can check the existing values using the command

```bash
aws route53 list-hosted-zones
```

The example of output:
```bash
$  aws route53 list-hosted-zones
{
    "HostedZones": [
        {
            "Id": "/hostedzone/Z076872934A7UXUIVRI",
            "Name": "nameofhosted874.info.",
            "CallerReference": "nameofhosted874.info2020-05-06 17:17:12.266120",
            "Config": {
                "Comment": "",
                "PrivateZone": false
            },
            "ResourceRecordSetCount": 2
        }
    ]
}
```
The resulting value should be written to the variables.tf file in the "DNSname" variable.
We can now run the "terraform init" command.


## Usage

We should run the "terraform apply" command.

```python
terraform apply
```
After running this command, we will receive an output that will display the name of our host for Jenkins CI.

For example
```bash
Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

Outputs:

aws_common_subnet_primary = subnet-025651715867ad3e0
aws_common_subnet_secondary = subnet-090c3c3c3f16d2faa
aws_worker_subnet = subnet-0720da6b8ff3b9283
dns = jenkins.nameofhosted874.info
internet-gateway-common = igw-055feb1672c7cc103
internet-gateway-worker = igw-09f4bc85ec95edace
jenkins-master-node-public-ip = 3.238.144.49
jenkins-worker-node-public-ip = {
  "i-05c7497d94758e455" = "54.200.227.35"
}
load_balancer_dns-name = jenkins-alb-1415846677.us-east-1.elb.amazonaws.com
vpc_common = 10.0.0.0/16
```

So now go to any browser and go to the dns name that we got from output. By default the username and password for Jenkins will be "admin:password".

![photo_2021-04-01 14 23 37](https://user-images.githubusercontent.com/20015341/113287206-eca7e100-92f5-11eb-88b6-b384a5af644d.jpeg)


# Documentation    

Full, comprehensive documentation is available on the Terraform website:

https://terraform.io/docs/providers/aws/index.html

