resource "aws_vpc" "base_vpc" {
  cidr_block           = var.cidr_block #"10.0.0.0/16"
  enable_dns_hostnames = true
  tags = merge ({
    Name = var.vpc_name,
  }, var.common_tags)
}

resource "aws_subnet" "private_subnet" {
  count = length(var.subnets)
  vpc_id = aws_vpc.base_vpc.id
  #cidr_block = "10.0.${count.index}.0/24"
  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : join("", aws_vpc.base_vpc.cidr_block),
    ceil(log(length(var.subnets) * 2, 2)),
    count.index
  )
  availability_zone= var.subnets[count.index]

  tags = merge ({
    Name = "private_subnet-${var.vpc_name}",
    availability_zone = "${var.subnets[count.index]}"
  }, var.common_tags)
}

resource "aws_internet_gateway" "base_igw" {
  vpc_id = aws_vpc.base_vpc.id

  tags = merge ({
    Name = "base_igw-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_route_table" "base_rt" {
  vpc_id = aws_vpc.base_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.base_igw.id
  }

  tags = merge ({
    Name = "base_rt-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_route_table_association" "route_table_subnet_association" {
  count = length(var.subnets)
  subnet_id     = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.base_rt.id
}


resource "aws_key_pair" "bastion_access" {
  key_name   = "bastion-key-${var.vpc_name}"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = merge ({
    Name = "bastion_access-${var.vpc_name}",
  }, var.common_tags)
}


resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.base_vpc.id
  ingress {
    description      = "ssh to bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks       = [var.admin_public_ip]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge ({
    Name = "bastion_sg-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_instance" "bastion" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  key_name = aws_key_pair.bastion_access.key_name

  network_interface {
    network_interface_id = aws_network_interface.bastion_eni.id
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  tags = merge ({
    Name = "bastion-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_network_interface" "bastion_eni" {
  subnet_id   = aws_subnet.private_subnet[0].id

  tags = merge ({
    Name = "bastion_eni-${var.vpc_name}",
  }, var.common_tags)
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.bastion_eni.id
  associate_with_private_ip = aws_instance.bastion.private_ip
}


resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.bastion_sg.id
  network_interface_id = aws_instance.bastion.primary_network_interface_id
}