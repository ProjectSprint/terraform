# Application Auto Scaling Target
resource "aws_appautoscaling_target" "example_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.projectsprint.name}/${aws_ecs_service.example_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU Utilization Scaling
resource "aws_appautoscaling_policy" "example_ecs_cpu_policy" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.example_target.resource_id
  scalable_dimension = aws_appautoscaling_target.example_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.example_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 80.0 # Target CPU utilization percentage
    scale_in_cooldown  = 300  # 5 minutes
    scale_out_cooldown = 300  # 5 minutes
  }
}

# Memory Utilization Scaling
resource "aws_appautoscaling_policy" "example_ecs_memory_policy" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.example_target.resource_id
  scalable_dimension = aws_appautoscaling_target.example_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.example_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0 # Target memory utilization percentage
    scale_in_cooldown  = 300  # 5 minutes
    scale_out_cooldown = 300  # 5 minutes
  }
}
