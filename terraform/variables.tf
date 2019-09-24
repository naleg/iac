variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "aws_profile" {
  type    = "string"
  default = "default"
}

variable "common_tags" {
  type = "map"
  default = {
  }
}

variable "deployment_name" {
  type    = "string"
  default = "rajesh"
}

variable "vpc_cidr" {
  type    = "string"
  default = "192.0.0.0/16"
}

variable "ssh_key" {
  type    = "string"
  default = "gudur"
}

variable "public_subnet" {
  type    = list(string)
  default = ["192.0.0.0/20", "192.0.16.0/20", "192.0.32.0/20"]
}

variable "private_subnet" {
  type    = "list"
  default = ["192.0.48.0/20", "192.0.64.0/20", "192.0.80.0/20"]
}

variable "availability_zones" {
  type    = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami" {
  type = "map"
  default = {
    ubuntu = {
      us-east-1 = "ami-024582e76075564db"
    }
  }
}