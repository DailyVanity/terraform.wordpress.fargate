
resource "aws_ecs_service" "wordpress-app" {
  name            = "${var.PROJECT_DOMAIN}"
  cluster         = data.aws_ecs_cluster.wordpress-cluster.id
  task_definition = aws_ecs_task_definition.wordpress-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [for subnet in data.aws_subnet.private : subnet.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.http.id]
  }
  desired_count = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.avenueone-sg-wordpress-alb-https-tg.arn
    container_name = "nginx-container"
    container_port = 80
  }
}

resource "aws_ecs_task_definition" "wordpress-task-definition" {
  family                   = "avenueone-sg-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::472137784967:role/ECSTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::472137784967:role/ECSTaskExecutionRole"
  dynamic "volume" {
    for_each = var.MOUNT_MAP
    content {
      name = volume.value.name
      efs_volume_configuration {
        file_system_id = volume.value.efs_id
        transit_encryption = "ENABLED"
        root_directory = volume.value.root_directory
      }
    }
  }  
  container_definitions    = jsonencode([
    {
      "name": "nginx-container",
      "image": "${aws_ecr_repository.nginx-container.repository_url}:${var.DEFAULT_DOCKER_TAG}",

      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "wordpress-group",
          "awslogs-region": "ap-southeast-1",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "${var.PROJECT_DOMAIN}-nginx"
        }        
      },
      "mountPoints": [for key, value in var.MOUNT_MAP : {
          "sourceVolume": value.name,
          "containerPath": value.container_path,
          "readOnly": false
      }]
    },
    {
      name      = "php-fpm-container"
      image     = "${aws_ecr_repository.php-fpm-container.repository_url}:${var.DEFAULT_DOCKER_TAG}"
      entryPoint = ["php-fpm"]
      essential = true
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "wordpress-group",
          "awslogs-region": "ap-southeast-1",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "${var.PROJECT_DOMAIN}-php-fpm"
        }        
      },
      "mountPoints": [for key, value in var.MOUNT_MAP : {
          "sourceVolume": value.name,
          "containerPath": value.container_path,
          "readOnly": false
      }]
    }
  ])
}