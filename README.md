# Jenkins master and worker solution unsing terraform and ansible

This automation is for installing and deploying Jenkins CI with a specific configuration that can be changed. The first version of the solution is now ready, which only works in AWS. It is planned to add modules for the multicloud infrastructure, which includes modules. I have prepared some diagram that will give you an understanding of the architecture.

![Terraform_ansible](https://user-images.githubusercontent.com/20015341/113224231-a752c780-9293-11eb-981c-5c77bf981414.png)


## Installation

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

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install boto3

```bash
pip install boto3
```

## Usage

```python
terraform apply
```

## Documentation    

in progress
