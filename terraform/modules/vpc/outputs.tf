output "vpc_id" {
  type  = "string"
  value = "${aws_vpc.main.id}"
}

output "public_subnets" {
  type  = "list"
  value = "${aws_subnet.public.*.id}"
}

output "private_subnets" {
  type  = "list"
  value = "${aws_subnet.private.*.id}"
}