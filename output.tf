output "alb_DNS" {
  value       = aws_lb.alb.dns_name
  description = "Application LB DNS"  
}