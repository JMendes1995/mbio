module "base_task1" {
  source = "../terraform/base"
  subnets = data.aws_availability_zones.available.names
  admin_public_ip = local.admin_public_ip
  cidr_block  = "10.0.0.0/16"
  vpc_name = "task_1_vpc"
  common_tags = {
    project = "mbio"
    module  = "base"
    task    = 1
  }
}

module "base_task2" {
  source = "../terraform/base"
  subnets = data.aws_availability_zones.available.names
  admin_public_ip = local.admin_public_ip
  cidr_block  = "20.0.0.0/16"
  vpc_name = "task_2_vpc"
  common_tags = {
    project = "mbio"
    module  = "base"
    task    = 2
  }
}

module "peering_connection" {
  source                = "../terraform/multi_vpc_connectivity"
  account_id            = data.aws_caller_identity.current.account_id
  task1_vpc_id          = module.base_task1.vpc_id
  task1_cidr_block      = "10.0.0.0/16"
  task1_route_table_id  = module.base_task1.route_table
  task2_vpc_id          = module.base_task2.vpc_id
  task2_cidr_block      = "20.0.0.0/16"
  task2_route_table_id  = module.base_task2.route_table
}
