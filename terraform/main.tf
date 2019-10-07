module "vpc" {
  source             = "./modules/vpc"
  public_subnet      = "${var.public_subnet}"
  private_subnet     = "${var.private_subnet}"
  availability_zones = "${var.availability_zones}"
  common_tags        = "${var.common_tags}"
  vpc_cidr           = "${var.vpc_cidr}"
  deployment_name    = "${var.deployment_name}"
}

module "private-nat" {
  source          = "./modules/private-nat"
  private_subnets = "${module.vpc.private_subnets}"
  public_subnet   = "${module.vpc.public_subnets[0]}"
  common_tags     = "${var.common_tags}"
  deployment_name = "${var.deployment_name}"
}