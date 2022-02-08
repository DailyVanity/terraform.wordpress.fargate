resource "aws_security_group" "service-sg" {
  name        = "${var.PROJECT_DOMAIN}-allow-traffic-from-alb"
  description = "Allow traffic from ALB for - ${var.PROJECT_DOMAIN}"
  vpc_id      = var.VPC_ID

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = var.DOCKER_LISTENING_PORT
    protocol         = "tcp"
    security_groups  = [
      data.aws_security_group.alb-sg.id
    ]    
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow public connection"
    ipv6_cidr_blocks = ["::/0"]
    self             = false
  }

  tags = {
    Name = "HTTPS & HTTP connection"
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }

}

resource "aws_security_group_rule" "alb-sg" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.service-sg.id
  depends_on = [
    aws_security_group.service-sg
  ]
}

# resource "aws_security_group" "fargate-service-sg" {
#   name        = "${var.PROJECT_DOMAIN}-fargate-service-alb-sg"
#   description = "Fargate service [${var.PROJECT_DOMAIN}] ALB Security Group"
#   vpc_id      = var.VPC_ID

#   egress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"    
#     description      = "Allow connecting to the ECS app"
#     cidr_blocks      = ["10.65.0.0/16"]
#     self             = false
#   }

#   egress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"    
#     description      = "Allow connecting to the ECS app"
#     cidr_blocks      = ["10.65.0.0/16"]
#     self             = false
#   }

#   tags = {
#     Name = "${var.PROJECT_DOMAIN} ALB Security group"
#     Environment = var.ENV
#     Domains     = var.PROJECT_DOMAIN
#     Project-Name= var.PROJECT_NAME
#   }
# }