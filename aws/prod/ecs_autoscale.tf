# resource "aws_appautoscaling_target" "team_targets" {
#   for_each = merge([
#     for team, config in local.team_ecs_configs : {
#       for idx, instance in config.ecs_instances :
#       "${team}-${idx}" => {
#         team     = team
#         instance = instance
#         idx      = idx
#       }
#     }
#   ]...)
# 
#   max_capacity       = each.value.instance.autoscaleInstancesTo
#   min_capacity       = each.value.instance.hasEcrImages ? 1 : 0
#   resource_id        = "service/${aws_ecs_cluster.projectsprint.name}/${each.key}-service"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# 
#   depends_on = [aws_ecs_service.team_services]
# 
#   tags = {
#     project      = "projectsprint"
#     name         = each.key
#     team_name    = each.value.team
#     instance_idx = each.value.idx
#   }
# }
# 
# resource "aws_appautoscaling_policy" "team_cpu_policies" {
#   for_each = merge([
#     for team, config in local.team_ecs_configs : {
#       for idx, instance in config.ecs_instances :
#       "${team}-${idx}" => {
#         team     = team
#         instance = instance
#         idx      = idx
#       }
#     }
#   ]...)
# 
#   name               = "${each.value.team}-${each.value.idx}-cpu-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.team_targets[each.key].resource_id
#   scalable_dimension = aws_appautoscaling_target.team_targets[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.team_targets[each.key].service_namespace
# 
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = each.value.instance.cpuUtilizationTrigger
#     scale_in_cooldown  = 10
#     scale_out_cooldown = 10
#   }
# 
#   depends_on = [aws_ecs_service.team_services]
# }
# 
# resource "aws_appautoscaling_policy" "team_memory_policies" {
#   for_each = merge([
#     for team, config in local.team_ecs_configs : {
#       for idx, instance in config.ecs_instances :
#       "${team}-${idx}" => {
#         team     = team
#         instance = instance
#         idx      = idx
#       }
#     }
#   ]...)
# 
#   name               = "${each.value.team}-${each.value.idx}-memory-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.team_targets[each.key].resource_id
#   scalable_dimension = aws_appautoscaling_target.team_targets[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.team_targets[each.key].service_namespace
# 
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     target_value       = each.value.instance.memoryUtilizationTrigger
#     scale_in_cooldown  = 10
#     scale_out_cooldown = 10
#   }
# 
#   depends_on = [aws_ecs_service.team_services]
# }
