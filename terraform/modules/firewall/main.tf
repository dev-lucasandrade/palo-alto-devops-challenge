data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "subnet-id"
    values = var.public_subnet_ids
  }
}

resource "aws_launch_template" "firewall" {
  name_prefix   = "${var.project_name}-${var.environment}-firewall-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-firewall"
      Type = "firewall"
    })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "firewall" {
  name                = "${var.project_name}-${var.environment}-firewall-asg"
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.firewall.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.firewall.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-firewall-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

resource "aws_lb_target_group" "firewall" {
  name     = "${var.project_name}-${var.environment}-fw-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-firewall-tg"
  })
}
