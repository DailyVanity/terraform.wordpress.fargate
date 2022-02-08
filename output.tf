output "alb_DNS" {
  value       = data.aws_lb.wordpress.dns_name
  description = "Application LB DNS"  
}