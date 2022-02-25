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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.VPC_ID]
  }

  tags = {
    type = "public"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_ecs_cluster" "wordpress-cluster" {
  cluster_name = var.PROD_WORDPRESS_CLUSTER_NAME
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

data "aws_security_group" "alb-sg" {
  name = var.COMMON_ALB_SG_NAME
}

data "aws_security_group" "db-sg" {
  name = var.COMMON_DB_SG_NAME
}