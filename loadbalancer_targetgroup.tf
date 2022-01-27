resource "aws_lb_target_group" "wordpress-alb-https-tg" {
  name     = "wordpress-alb-tg"
  port     = 443
  protocol = "HTTPS"
  target_type = "ip"
  vpc_id   = var.VPC_ID
  tags = {
    Environment = "production"
  }
  health_check {
    enabled = true
    path = "/alb-health-check"
    port = 80
    protocol = "HTTP"
    matcher = "200"
  }
}
