resource "aws_ecr_repository" "descheduler-repo" {
  name = "${var.deployment_name}-descheduler"
}