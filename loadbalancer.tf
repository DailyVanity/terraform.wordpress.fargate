resource "aws_lb" "alb" {
  name               = "${var.PROJECT_NAME}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb-sg.id, aws_security_group.fargate-service-sg.id]
  subnets            = [for subnet in data.aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = var.LOAD_BALANCER_LOGS_BUCKET
    prefix  = "${var.PROD_LOG_PREFIX}/${var.PROJECT_NAME}-alb"
    enabled = true
  }

  tags = {
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }
}