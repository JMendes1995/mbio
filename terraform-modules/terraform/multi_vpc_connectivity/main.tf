resource "aws_vpc_peering_connection" "task_pc" {
  peer_owner_id = var.account_id
  peer_vpc_id   = var.task1_vpc_id
  vpc_id        = var.task2_vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between task1 vpc and task2 vpc"
  }
}


resource "aws_vpc_peering_connection_accepter" "remote" {
  vpc_peering_connection_id = aws_vpc_peering_connection.task_pc.id
  auto_accept               = true
}

resource "aws_route" "task1_pc_route" {
  route_table_id            = var.task1_route_table_id
  destination_cidr_block    = var.task2_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.task_pc.id
}

resource "aws_route" "task2_pc_route" {
  route_table_id            = var.task2_route_table_id
  destination_cidr_block    = var.task1_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.task_pc.id
}