output "vpc_id" {
  value = aws_vpc.base_vpc.id
}

output "ssh_pub_key" {
  value = aws_key_pair.bastion_access.public_key
}

output "network_ids" {
  value = aws_subnet.private_subnet.*.id
}

output "availability_zones" {
  value = var.subnets
}

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "route_table" {
  value = aws_route_table.base_rt.id
}

output "key_name" {
  value = aws_key_pair.bastion_access.key_name
}

output vpc_name {
  value = var.vpc_name
}