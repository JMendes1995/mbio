variable "common_tags" {
  type = map(string)
}
variable "subnets" {
  type = list(string)
}

variable "admin_public_ip" {}

variable "cidr_block" {}

variable "vpc_name" {}