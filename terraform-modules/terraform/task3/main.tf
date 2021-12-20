resource "aws_security_group" "task3_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    security_groups = [var.bastion_sg]
  }
  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    security_groups = [var.bastion_sg]
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self = true
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge ({
    Name = "task3_sg-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_instance" "task3" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  key_name = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.task3_eni.id
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  tags = merge ({
    Name = "task3-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_network_interface" "task3_eni" {
  subnet_id   = var.subnets[0]

  tags = merge ({
    Name = "task3_eni-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_eip" "task3_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.task3_eni.id
  associate_with_private_ip = aws_instance.task3.private_ip
}


resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.task3_sg.id
  network_interface_id = aws_instance.task3.primary_network_interface_id
}


resource "aws_db_subnet_group" "task3_subnet_group" {
  name       = "task3"
  subnet_ids = var.subnets

  tags = merge ({
    Name = "task3_subnet_group-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_db_instance" "task3_rds" {
  identifier = "task3-db"
  vpc_security_group_ids = [aws_security_group.task3_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.task3_subnet_group.name
  allocated_storage    = 8
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"

  maintenance_window      = "Fri:09:00-Fri:09:30"

  backup_retention_period = 1
  skip_final_snapshot  = true
}