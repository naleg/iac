data "http" "myip" {
  url = "https://api.ipify.org"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/*/ubuntu-*18*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}


output "current_ip" {
  value = "${chomp(data.http.myip.body)}"
}