resource "aws_iam_role" "EKSMaster" {
  name = "${var.deployment_name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = "${aws_iam_role.EKSMaster.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = "${aws_iam_role.EKSMaster.name}"
}



resource "aws_security_group" "EKSMaster" {
  name = "${var.deployment_name}-EKSMaster"
  description = "Cluster communication with worker nodes"
  vpc_id = "${module.vpc.vpc_id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.common_tags}"
}

resource "aws_security_group_rule" "EKSMaster-ingress-https" {
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow workstation to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.EKSMaster.id}"
  to_port = 443
  type = "ingress"
}


resource "aws_eks_cluster" "cluster" {
  name = "${var.deployment_name}"
  role_arn = "${aws_iam_role.EKSMaster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.EKSMaster.id}"]
    subnet_ids = "${module.vpc.public_subnets}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]
}

locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.cluster.name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}



resource "aws_iam_role" "worker-node" {
  name = "${var.deployment_name}_eks_worker"

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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = "${aws_iam_role.worker-node.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = "${aws_iam_role.worker-node.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = "${aws_iam_role.worker-node.name}"
}

resource "aws_iam_instance_profile" "worker-node" {
  name = "${var.deployment_name}_eks_worker_profile"
  role = "${aws_iam_role.worker-node.name}"
}

resource "aws_security_group" "worker-node" {
  name = "${var.deployment_name}_eks_worker"
  description = "Security group for all nodes in the cluster"
  vpc_id = "${module.vpc.vpc_id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.common_tags, map(
     "Name", "${var.deployment_name}_eks_worker",
     "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}", "owned",
    ))}"
}

resource "aws_security_group_rule" "worker-node-ingress-self" {
  description = "Allow node to communicate with each other"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.worker-node.id}"
  source_security_group_id = "${aws_security_group.worker-node.id}"
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-cluster" {
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port = 1025
  protocol = "tcp"
  security_group_id = "${aws_security_group.worker-node.id}"
  source_security_group_id = "${aws_security_group.EKSMaster.id}"
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.EKSMaster.id}"
  source_security_group_id = "${aws_security_group.worker-node.id}"
  to_port = 443
  type = "ingress"
}

data "aws_ami" "eks-worker" {
  filter {
    name = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cluster.version}-v*"]
  }

  most_recent = true
  owners = ["602401143452"] # Amazon EKS AMI Account ID
}
data "aws_region" "current" {}

locals {
  worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority.0.data}' '${aws_eks_cluster.cluster.name}'
USERDATA
}

resource "aws_launch_configuration" "worker-node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.worker-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "c5.large"
  name_prefix                 = "${var.deployment_name}_eks_worker"
  security_groups             = ["${aws_security_group.worker-node.id}"]
  user_data_base64            = "${base64encode(local.worker-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.worker-node.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${var.deployment_name}_eks_worker"
  vpc_zone_identifier  = "${module.vpc.public_subnets}"

  tag {
    key                 = "Name"
    value               = "${var.deployment_name}_eks_worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}