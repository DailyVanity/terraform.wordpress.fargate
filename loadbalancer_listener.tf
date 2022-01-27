resource "aws_lb_listener_certificate" "domain-cert" {
  listener_arn    = data.aws_lb_listener.https_listener.arn
  certificate_arn = data.aws_acm_certificate.issued.arn
}

resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = data.aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-alb-https-tg.arn
  }

  condition {
    host_header {
      values = [var.PROJECT_DOMAIN]
    }
  }
}