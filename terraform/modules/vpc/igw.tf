resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = merge(var.common_tags,
  map("Name", "${var.deployment_name}_igw"))
}

resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = merge(var.common_tags,
  map("Name", "${var.deployment_name}_igw"))
}

resource "aws_route_table_association" "rta_subnet_public" {
  count          = "${length(aws_subnet.public)}"
  subnet_id      = "${aws_subnet.public[count.index].id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}