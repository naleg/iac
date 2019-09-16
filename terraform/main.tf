module "vpc" {
  source             = "./modules/vpc"
  public_subnet      = var.public_subnet
  private_subnet     = var.private_subnet
  availability_zones = var.availability_zones
  common_tags        = var.common_tags
  vpc_cidr           = var.vpc_cidr
  deployment_name    = var.deployment_name
}

resource "aws_instance" "jenkins" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t3.large"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  key_name               = "gudur"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags = merge(var.common_tags,
  map("Name", "Jenkins"))
}