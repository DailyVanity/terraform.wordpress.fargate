resource "aws_appautoscaling_target" "scale-task" {
  max_capacity       = var.AUTO_SCALING.max
  min_capacity       = var.AUTO_SCALING.min
  resource_id        = "service/${var.PROD_WORDPRESS_CLUSTER_NAME}/${aws_ecs_service.wordpress-app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

locals {
  alb = slice(split("/", data.aws_lb.wordpress.id), 1, length(split("/", data.aws_lb.wordpress.id)))
  target_group = slice(split("/", aws_lb_target_group.alb-https-tg.id), 1, length(split("/", aws_lb_target_group.alb-https-tg.id)))
}


resource "aws_appautoscaling_policy" "ecs_policy" {
  for_each = var.TARGET_SCALING.CONFIG
  name               = "${var.PROJECT_NAME} ${each.key} Scaling Policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.scale-task.resource_id
  scalable_dimension = aws_appautoscaling_target.scale-task.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scale-task.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = each.value.target_value
    scale_in_cooldown = each.value.scale_in
    scale_out_cooldown = each.value.scale_out
    predefined_metric_specification {
      predefined_metric_type = each.key
      resource_label=each.key=="ALBRequestCountPerTarget"?"${local.alb[0]}/${local.alb[1]}/${local.alb[2]}/targetgroup/${local.target_group[0]}/${local.target_group[1]}":null
    }
  }
  depends_on = [
    aws_lb_target_group.alb-https-tg
  ]
}
resource "aws_appautoscaling_scheduled_action" "ecs_scheduled_scaling" {
  for_each = var.SCHEDULE_SCALING.schedule
  name               = each.key
  service_namespace  = aws_appautoscaling_target.scale-task.service_namespace
  resource_id        = aws_appautoscaling_target.scale-task.resource_id
  scalable_dimension = aws_appautoscaling_target.scale-task.scalable_dimension
  schedule           = each.value.time
  timezone           = each.value.timezone

  scalable_target_action {
    min_capacity = each.value.min
    max_capacity = each.value.max
  }
}