resource "aws_eip" "nat" {
  vpc  = true
  tags = "${merge(var.common_tags, map("Name", "${var.deployment_name}-nat-ip"))}"
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${var.public_subnet}"
  tags          = "${merge(var.common_tags, map("Name", "${var.deployment_name}-nat-gateway"))}"
}

resource "aws_route_table" "rtb_private" {
  vpc_id = "${data.aws_subnet.public.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags = "${merge(var.common_tags, map("Name", "${var.deployment_name}-private-gw"))}"
}

resource "aws_route_table_association" "rta_subnet_private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${var.private_subnets[count.index]}"
  route_table_id = "${aws_route_table.rtb_private.id}"
}