resource "aws_lb_listener" "redirect_http_https" {
  load_balancer_arn = aws_lb.alb.arn
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
resource "aws_lb_listener" "default_listener_rule" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-https-tg.arn
  }
}

resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = aws_lb_listener.default_listener_rule.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-https-tg.arn
  }

  condition {
    host_header {
      values = var.LISTENING_DOMAINS
    }
  }
}