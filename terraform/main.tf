module "vpc" {
  source = "./modules/vpc"
  public_subnet = var.public_subnet
  private_subnet = var.private_subnet
  availability_zones = var.availability_zones
  common_tags = var.common_tags
  vpc_cidr = var.vpc_cidr
  deployment_name = var.deployment_name
}

