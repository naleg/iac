variable "common_tags" {
  type = "map"
  default = {
  }
}

variable "deployment_name" {
  type    = "string"
  default = "rajesh"
}

variable "private_subnets" {
  type = "list"
}

variable "public_subnet" {
  type = "string"
}

data "aws_subnet" "public" {
  id = "${var.public_subnet}"
}