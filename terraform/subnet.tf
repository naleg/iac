resource "aws_subnet" "public" {
  count             = "${length(var.public_subnet)}"
  cidr_block        = "${var.public_subnet[count.index]}"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_availability_zones[count.index]}"
  tags = merge(var.common_tags,
  map("Name", "${var.deployment_name}_public_${count.index + 1}"))
}

resource "aws_subnet" "private" {
  count             = "${length(var.private_subnet)}"
  cidr_block        = "${var.private_subnet[count.index]}"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_availability_zones[count.index]}"
  tags = merge(var.common_tags,
  map("Name", "${var.deployment_name}_private_${count.index + 1}"))
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}