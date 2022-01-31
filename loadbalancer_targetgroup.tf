resource "aws_lb_target_group" "alb-https-tg" {
  name     = "${var.PROJECT_NAME}-alb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.VPC_ID
  tags = {
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }
  health_check {
    enabled = true
    path = "/alb-health-check.html"
    port = var.DOCKER_LISTENING_PORT
    protocol = "HTTP"
    matcher = "200"
  }
}
