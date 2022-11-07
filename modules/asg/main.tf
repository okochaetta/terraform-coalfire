# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DATA RESOURCE TO FETCH RHEL 8.5
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "aws_ami" "rhel" {
  count = var.image_id == "" ? 1 : 0
  
  most_recent = true
  owners      = ["309956199498"] // Red Hat's Account ID

  filter {
    name   = "name"
    values = ["RHEL-8.5*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EC2 LAUNCH TEMPLATE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_launch_configuration" "main" {
  image_id      = var.image_id == "" ? data.aws_ami.rhel[0].id : var.image_id
  instance_type = var.instance_type
  user_data     = file("${path.module}/scripts/userdata.sh")
  
  associate_public_ip_address = var.associate_public_ip_address

  security_groups = [
    aws_security_group.backend.id
  ]

  root_block_device {
    volume_size           = var.root_block_device_size
    volume_type           = var.root_block_device_type
    delete_on_termination = true
    encrypted             = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AUTOSCALING GROUP
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_autoscaling_group" "main" {
  launch_configuration = aws_launch_configuration.main.name
  health_check_type    = var.health_check_type
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  vpc_zone_identifier  = var.private_subnet_ids

  target_group_arns = [
    aws_lb_target_group.main.arn
  ]

  tag {
    key                 = "Name" 
    value               = "${var.application}-${var.environment}-asg"
    propagate_at_launch = true
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPLICATION LAOD BALANCER, LISTNER AND LISTENER RULE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_lb" "main" {
  name               = "${var.application}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = var.load_balancer_subnet_ids

  security_groups = [
    aws_security_group.alb.id
  ]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# LOAD BALANCER TARGET GROUP
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_lb_target_group" "main" {
  name     = "${var.application}-${var.environment}-tg"
  port     = var.backend_web_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/" 
    protocol = "HTTP"
    matcher  = "200"
    interval = 15
    timeout  = 3

    healthy_threshold   = 2
    unhealthy_threshold = 2
  } 
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECURITY GROUPS FOR CONNECTIVITY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "alb" {
  name        = "${var.application}-${var.environment}-lb-sg"
  vpc_id      = var.vpc_id
  description = "Allow inbound HTTP traffic on application load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Accept inbound HTTP traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name        = "${var.application}-${var.environment}-backend-sg"
  vpc_id      = var.vpc_id
  description = "Allow inbound HTTP traffic on backend servers from ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    security_groups = [aws_security_group.alb.id]
    description     = "Accept inbound HTTP traffic from ALB"
  }  
}
