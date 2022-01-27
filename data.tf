data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.VPC_ID]
  }

  tags = {
    type = "private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_ecs_cluster" "wordpress-cluster" {
  cluster_name = "prod-wordpress-cluster"
}

data "aws_lb" "wordpress" {  
  name = var.ALB_NAME
}

data "aws_lb_listener" "https_listener" {
  load_balancer_arn = data.aws_lb.wordpress.arn
  port = 443
}

data "aws_acm_certificate" "issued" {
  domain   = var.CERT_DOMAIN
  statuses = ["ISSUED"]
}