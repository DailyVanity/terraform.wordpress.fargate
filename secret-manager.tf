resource "aws_secretsmanager_secret" "app_secret" {
  name = "${var.ENV}/${var.PROJECT_NAME}-app_secret"
}

# resource "aws_secretsmanager_secret_policy" "app_secret_policy" {
#   secret_arn = aws_secretsmanager_secret.app_secret.arn

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "EnableAnotherAWSAccountToReadTheSecret",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::123456789012:root"
#       },
#       "Action": "secretsmanager:GetSecretValue",
#       "Resource": "*"
#     }
#   ]
# }
# POLICY
# }