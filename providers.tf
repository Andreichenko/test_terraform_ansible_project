provider "aws" {
  profile     = var.profile
  region      = var.region-common
  alias       = "region-common"

}

provider "aws" {
  profile     = var.profile
  region      = var.region-worker
  alias       = "region-worker"
}