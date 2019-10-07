resource "aws_instance" "main" {
  ami           = "${var.ami.ubuntu.us-east-1}"
  instance_type = "t3.medium"
  subnet_id     = "${module.vpc.public_subnets[0]}"
  key_name      = "${var.ssh_key}"
  root_block_device {
    volume_size = 50
  }
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  tags                   = "${merge(var.common_tags, map("Name", "Main"))}"
}

output "main_ip" {
  value = "${aws_instance.main.public_ip}"
}