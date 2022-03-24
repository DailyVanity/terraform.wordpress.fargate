
resource "aws_ecs_service" "wordpress-app" {
  name            = "${var.PROJECT_NAME}"
  cluster         = data.aws_ecs_cluster.wordpress-cluster.id
  task_definition = aws_ecs_task_definition.wordpress-task-definition.arn  
  network_configuration {
    subnets          = [for subnet in data.aws_subnet.private : subnet.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.service-sg.id]
  }
  desired_count = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.alb-https-tg.arn
    container_name = "nginx-container"
    container_port = 80
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.CLUSTER_CAPACITY_WEIGHT
    content {
      base = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.key
      weight = capacity_provider_strategy.value.weight
    }
  }  

  tags = {
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.PROVIDER_STRATEGY
    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.key
      weight            = capacity_provider_strategy.value.weight
    }
  }
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
    create_before_destroy = true
  }
  
}

resource "aws_ecs_task_definition" "wordpress-task-definition" {
  family                   = "${var.PROJECT_NAME}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.MEMORY
  cpu                      = var.CPU
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.tasks_role.arn
  dynamic "volume" {
    for_each = var.MOUNT_MAP
    content {
      name = volume.value.name
      efs_volume_configuration {
        file_system_id = volume.value.file_system_id
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
          "awslogs-group": "${var.LOG_GROUP}",
          "awslogs-region": "${var.REGION}",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "${var.PROJECT_DOMAIN}"
        }        
      },
      "mountPoints": [for key, value in var.MOUNT_MAP : {
          "sourceVolume": value.name,
          "containerPath": value.container_path,
          "readOnly": false
      }],
      "secrets": [for key, value in var.CONTAINER_SECRET : {
          "name": key,
          "valueFrom": "${aws_secretsmanager_secret.app_secret.arn}:${value}::"
      }]
    },
    {
      name      = "php-fpm-container"
      image     = "${aws_ecr_repository.php-fpm-container.repository_url}:${var.DEFAULT_DOCKER_TAG}"
      command = ["php-fpm", "--nodaemonize", "--force-stderr", "--fpm-config", "/etc/php7/php-fpm.d/www.conf"]
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
          "awslogs-group": "${var.LOG_GROUP}",
          "awslogs-region": "${var.REGION}",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "${var.PROJECT_DOMAIN}"
        }        
      },
      "mountPoints": [for key, value in var.MOUNT_MAP : {
          "sourceVolume": value.name,
          "containerPath": value.container_path,
          "readOnly": false
      }],
      "secrets": [for key, value in var.CONTAINER_SECRET : {
          "name": key,
          "valueFrom": "${aws_secretsmanager_secret.app_secret.arn}:${value}::"
      }]
    }
  ])
  # lifecycle {
  #   ignore_changes = [
  #     container_definitions
  #   ]
  # }
  depends_on = [
    aws_iam_role.tasks_role
  ]
}