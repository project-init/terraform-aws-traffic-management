locals {
  secure_token    = var.secure_token == "" ? data.aws_ssm_parameter.secure_token[0].value : var.secure_token
  api_domain_name = "api.${var.domain}"
  origin_name     = "internal-alb-vpc-origin"
}

########################################################################################################################
### Internal Load Balancer
########################################################################################################################

data "aws_ssm_parameter" "secure_token" {
  count = var.secure_token == "" ? 1 : 0
  name  = "/${var.environment}/internal-alb/secure-token"
}

resource "aws_ssm_parameter" "secure_token" {
  name  = "/${var.environment}/internal-alb/secure-token"
  type  = "SecureString"
  value = var.secure_token

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_alb" "internal_load_balancer" {
  name                       = "${var.environment}-internal-alb"
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = var.private_subnet_ids
  security_groups            = [aws_security_group.internal_load_balancer.id]
  enable_deletion_protection = true

  tags = {
    Name = "${var.environment}-internal-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.internal_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.internal_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_listener" "https_prelive" {
  load_balancer_arn = aws_alb.internal_load_balancer.arn
  port              = "9001"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name             = "public-api-${var.environment}-tg"
  target_type      = "ip"
  port             = 80
  protocol         = "HTTPS"
  protocol_version = "HTTP1"
  vpc_id           = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    timeout             = 2
    protocol            = "HTTP"
    matcher             = 200
    unhealthy_threshold = 2
    path                = var.api_health_check_path
  }
}

resource "aws_lb_target_group" "api_prelive" {
  name             = "public-api-${var.environment}-prelive-tg"
  target_type      = "ip"
  port             = 80
  protocol         = "HTTPS"
  protocol_version = "HTTP1"
  vpc_id           = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    timeout             = 2
    protocol            = "HTTP"
    matcher             = 200
    unhealthy_threshold = 2
    path                = var.api_health_check_path
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    http_header {
      http_header_name = "X-Allow"
      values           = [local.secure_token]
    }
  }

  condition {
    host_header {
      values = [local.api_domain_name]
    }
  }
}

resource "aws_lb_listener_rule" "api_prelive" {
  listener_arn = aws_lb_listener.https_prelive.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    host_header {
      values = [local.api_domain_name]
    }
  }
}

# The security group allows all traffic across the vpc, and traffic from the cloudfront distribution.
resource "aws_security_group" "internal_load_balancer" {
  name        = "${var.environment}-internal-alb-sg"
  description = "Allow inbound and outbound traffic to/from the ${var.environment} internal ALB."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-internal-alb-sg"
  }
}

resource "aws_security_group_rule" "internal_load_balancer_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.ipv4_primary_cidr_block]
  security_group_id = aws_security_group.internal_load_balancer.id
}

resource "aws_security_group_rule" "internal_load_balancer_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.ipv4_primary_cidr_block]
  security_group_id = aws_security_group.internal_load_balancer.id
}

resource "aws_security_group_rule" "internal_load_balancer_https_prelive_ingress" {
  type              = "ingress"
  from_port         = 9001
  to_port           = 9001
  protocol          = "tcp"
  cidr_blocks       = [var.ipv4_primary_cidr_block]
  security_group_id = aws_security_group.internal_load_balancer.id
}

data "aws_ec2_managed_prefix_list" "cloudfront_prefix_list" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "internal_load_balancer_https_ingress_cloudfront" {
  security_group_id = aws_security_group.internal_load_balancer.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront_prefix_list.id]
}

resource "aws_security_group_rule" "internal_load_balancer_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.internal_load_balancer.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}