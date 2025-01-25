resource "aws_appautoscaling_target" "team_targets" {
  for_each           = local.autoscaling_teams
  max_capacity       = each.value.ecs_instances[0].autoscaleInstancesTo
  min_capacity       = each.value.ecs_instances[0].hasEcrImages ? 1 : 0
  resource_id        = "service/${aws_ecs_cluster.projectsprint.name}/${aws_ecs_service.team_services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    project     = "projectsprint"
    environment = "generated"
    team_name   = each.key
  }
}

resource "aws_appautoscaling_policy" "team_cpu_policies" {
  for_each           = local.autoscaling_teams
  name               = "${each.key}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.team_targets[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.team_targets[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.team_targets[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = each.value.ecs_instances[0].cpuUtilizationTrigger
    scale_in_cooldown  = 10
    scale_out_cooldown = 10
  }
}

resource "aws_appautoscaling_policy" "team_memory_policies" {
  for_each           = local.autoscaling_teams
  name               = "${each.key}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.team_targets[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.team_targets[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.team_targets[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = each.value.ecs_instances[0].memoryUtilizationTrigger
    scale_in_cooldown  = 10
    scale_out_cooldown = 10
  }
}
