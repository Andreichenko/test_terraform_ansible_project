terraform {
  required_version    =    ">=0.12.0"
  backend "s3" {
    region    = "us-east-1"
    profile   = "default"
    key       = "terraform-state-file"
    bucket    = "terraform-state-bucket6655"
  }
}