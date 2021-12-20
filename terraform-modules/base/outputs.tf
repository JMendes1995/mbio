output "vpc_id" {
  value = module.base_task1.vpc_id
}

output "ssh_pub_key" {
  value = module.base_task1.ssh_pub_key
}

output "network_ids" {
  value = module.base_task1.network_ids
}

output "availability_zones" {
  value = module.base_task1.availability_zones
}
output "bastion_sg" {
  value = module.base_task1.bastion_sg
}
output "key_name" {
  value = module.base_task1.key_name
}

output "task2_bastion_sg" {
  value = module.base_task2.bastion_sg
}

output "task2_vpc_id" {
  value = module.base_task2.vpc_id
}

output "task2_network_ids" {
  value = module.base_task2.network_ids
}

output "task2_vpc_name" {
  value = module.base_task2.vpc_name
}

output "task2_key_name" {
  value = module.base_task2.key_name
}