resource "aws_instance" "main" {
  ami           = "${var.ami.ubuntu.us-east-1}"
  instance_type = "c5.xlarge"
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

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.deployment_name}_ec2_profile"
  role = "${aws_iam_role.admin_role.name}"
}

resource "aws_iam_role" "admin_role" {
  name               = "${var.deployment_name}-ec2-admin-role"
  tags               = "${var.common_tags}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "admin_policy" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }
}
POLICY
}

resource "aws_iam_policy_attachment" "admin_role_attachment" {
name       = "${var.deployment_name}-ec2-admin-role-attachment"
roles      = ["${aws_iam_role.admin_role.name}"]
policy_arn = "${aws_iam_policy.admin_policy.arn}"
}