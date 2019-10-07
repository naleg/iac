output "vpc" {
  value = "${module.vpc}"
}

output "nat_ip" {
  value = "${module.private-nat.nat_ip}"
}