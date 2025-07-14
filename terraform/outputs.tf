output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.alb.alb_zone_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "firewall_instances" {
  description = "Firewall instance IDs"
  value       = module.firewall.firewall_instance_ids
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.compute.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.compute.service_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = module.monitoring.log_group_name
}
