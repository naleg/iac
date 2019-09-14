variable "aws_region" {
  type = "string"
  default = "us-east-1"
}

variable "aws_profile" {
  type = "string"
  default = "default"
}

variable "common_tags" {
  type = "map"
  default = {
}
}

variable "deployment_name" {
	type = "string"
	default = "rajesh"
}

variable "vpc_cidr" {
	type = "string"
	default = "192.0.0.0/16"
}