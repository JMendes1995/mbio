module "nginx" {
  source = "../terraform/nginx"
  subnets = data.terraform_remote_state.base.outputs.network_ids
  vpc_id  = data.terraform_remote_state.base.outputs.vpc_id
  ssh_bastion_key = data.terraform_remote_state.base.outputs.ssh_pub_key
  az              = data.terraform_remote_state.base.outputs.availability_zones
  bastion_sg      = data.terraform_remote_state.base.outputs.bastion_sg
  key_name        = data.terraform_remote_state.base.outputs.key_name
  task2_bastion_sg = data.terraform_remote_state.base.outputs.task2_bastion_sg

  common_tags = {
    project = "mbio"
    module  = "nginx"
  }
}