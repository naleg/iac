provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}

terraform {
  backend "remote" {
    organization = "rajeshg007"

    workspaces {
      name = "iac"
    }
  }
}