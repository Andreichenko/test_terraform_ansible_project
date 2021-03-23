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


