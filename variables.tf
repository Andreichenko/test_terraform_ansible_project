variable "profile" {
  type        = string
  default     = "default"
}

variable "region-common" {
  type        = string
  default     = "us-east-1"
}

variable "region-worker" {
  type        = string
  default     = "us-west-2"
}

variable "external_ip" {
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "workers-count" {
  type = string
  default = 1
}

variable "webserver-port" {
  type = number
  default = 8080
}

variable "dnsname" {
  type = string
  default = "cmcloudlab494.info."
  # aws route53 list-hosted-zones
}


