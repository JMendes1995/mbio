resource "aws_security_group" "nginx_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    security_groups = [var.bastion_sg]
  }
  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    security_groups = [var.bastion_sg]
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self = true
  }
  ingress {
    from_port = 80
    protocol  = "TCP"
    to_port   = 80
    security_groups = [var.task2_bastion_sg]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge ({
    Name = "nginx_sg",
  }, var.common_tags)
}

resource "aws_launch_template" "nginx_launch_template" {
  name_prefix   = "nginx_launch_template"
  image_id      = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  key_name = var.key_name
  tag_specifications {
    resource_type = "instance"

  tags = merge ({
    Name = "nginx-node"
    kubernetes = true

  }, var.common_tags)
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.nginx_sg.id]
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }
}

resource "aws_autoscaling_group" "nginx_nodes" {
  count = length(var.subnets)
  name = "nginx_autoscaling_${count.index}"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  vpc_zone_identifier       = [var.subnets[count.index]]

  launch_template {
    id      = aws_launch_template.nginx_launch_template.id
    version = "$Latest"
  }

  tags = concat(
    [
      merge({
            "Name" = "nginx-${var.az[count.index]}"

      },var.common_tags)
    ]
  )
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = var.vpc_id

  tags = merge ({
    Name = "nginx_lb",
  }, var.common_tags)
  depends_on = [aws_autoscaling_group.nginx_nodes]

}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  count = length(var.subnets)
  autoscaling_group_name = aws_autoscaling_group.nginx_nodes[count.index].id
  alb_target_group_arn   = aws_lb_target_group.nginx_tg.arn
}


resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = var.subnets


  tags = merge ({
    Name = "nginx_lb",
  }, var.common_tags)
  depends_on = [aws_autoscaling_group.nginx_nodes]
}

resource "aws_lb_listener" "nginx_lb_listner" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx_tg.id
    type             = "forward"
  }
  tags = merge ({
    Name = "nginx_lb_listener",
  }, var.common_tags)
  depends_on = [aws_autoscaling_group.nginx_nodes]

}
