module "task3" {
  source = "../terraform/task3"
  subnets = data.terraform_remote_state.base.outputs.task2_network_ids
  vpc_id  = data.terraform_remote_state.base.outputs.task2_vpc_id
  vpc_name = data.terraform_remote_state.base.outputs.task2_vpc_name
  bastion_sg = data.terraform_remote_state.base.outputs.task2_bastion_sg
  key_name   = data.terraform_remote_state.base.outputs.task2_key_name
  db_password = var.db_password

  common_tags = {
    project = "mbio"
    module  = "task3"
  }
}