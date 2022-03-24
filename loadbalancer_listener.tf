resource "aws_lb_listener_certificate" "app-ssl-cert" {
  listener_arn    = data.aws_lb_listener.https_listener.arn
  certificate_arn = data.aws_acm_certificate.issued.arn
}

resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = data.aws_lb_listener.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-https-tg.arn
  }

  condition {
    host_header {
      values = var.LISTENING_DOMAINS
    }
  }
  tags = {
    Name = "Domain allowed"
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }
}