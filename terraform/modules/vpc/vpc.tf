resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(var.common_tags, map("Name", "${var.deployment_name}_vpc"))}"
}