variable "subnets" {}

variable "common_tags" {
  type = map(string)
}
variable "vpc_id" {}

variable "ssh_bastion_key" {}

variable "az" {}

variable "bastion_sg" {}

variable "key_name" {}

variable "task2_bastion_sg" {}