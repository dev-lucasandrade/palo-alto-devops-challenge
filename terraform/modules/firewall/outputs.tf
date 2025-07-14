output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.firewall.id
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_autoscaling_group.firewall.name
}

output "autoscaling_group_arn" {
  description = "ARN of the autoscaling group"
  value       = aws_autoscaling_group.firewall.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.firewall.arn
}

output "firewall_instance_ids" {
  description = "List of firewall instance IDs"
  value       = aws_autoscaling_group.firewall.id
}
