resource "aws_iam_role" "tasks_role" {
  name = "${var.PROJECT_NAME}-task-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.ENV
    Domains     = var.PROJECT_DOMAIN
    Project-Name= var.PROJECT_NAME
  }
}

resource "aws_iam_role_policy" "standard_policy" {
  name = "${var.PROJECT_NAME}-standard_policy"
  role = aws_iam_role.tasks_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : "logs:*",
        "Resource" : [
          "arn:aws:logs:${var.REGION}:${var.ACC_ID}:log-group:${var.LOG_GROUP}",
          "arn:aws:logs:${var.REGION}:${var.ACC_ID}:destination:${var.PROJECT_NAME}*"
        ]
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.S3_ASSET_BUCKET}",
          "arn:aws:s3:::${var.S3_ASSET_BUCKET}/*"
        ]
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "${aws_secretsmanager_secret.app_secret.arn}"
        ]
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : "ecr:*",
        "Resource" : [
          "${aws_ecr_repository.php-fpm-container.arn}",
          "${aws_ecr_repository.nginx-container.arn}"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "efs_policy" {
  name = "${var.PROJECT_NAME}-efs_policy"
  role = aws_iam_role.tasks_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "elasticfilesystem:*",
        "Resource" : "*"
      },
    ]
  })
}
