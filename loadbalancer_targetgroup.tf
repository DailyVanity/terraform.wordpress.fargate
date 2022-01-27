resource "aws_lb_target_group" "avenueone-sg-wordpress-alb-https-tg" {
  name     = "avenueone-sg-wordpress-alb-tg"
  port     = 443
  protocol = "HTTPS"
  target_type = "ip"
  vpc_id   = var.VPC_ID
  tags = {
    Environment = "production"
  }
}
