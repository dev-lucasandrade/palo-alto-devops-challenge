data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name       = var.project_name
  environment        = var.environment
  tags               = local.common_tags
}

module "security" {
  source = "./modules/security"

  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "firewall" {
  source = "./modules/firewall"

  vpc_id                  = module.networking.vpc_id
  public_subnet_ids       = module.networking.public_subnet_ids
  private_subnet_ids      = module.networking.private_subnet_ids
  security_group_id       = module.security.firewall_security_group_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  project_name            = var.project_name
  environment             = var.environment
  tags                    = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  security_group_id       = module.security.ecs_security_group_id
  execution_role_arn      = module.security.ecs_execution_role_arn
  task_role_arn           = module.security.ecs_task_role_arn
  container_image         = var.container_image
  container_port          = var.container_port
  desired_count           = var.desired_count
  project_name            = var.project_name
  environment             = var.environment
  tags                    = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  security_group_id     = module.security.alb_security_group_id
  target_group_arn      = module.compute.target_group_arn
  waf_acl_arn           = module.security.waf_acl_arn
  project_name          = var.project_name
  environment           = var.environment
  tags                  = local.common_tags
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id                  = module.networking.vpc_id
  public_subnet_ids       = module.networking.public_subnet_ids
  security_group_id       = module.security.bastion_security_group_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  project_name            = var.project_name
  environment             = var.environment
  tags                    = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  cluster_name     = module.compute.cluster_name
  service_name     = module.compute.service_name
  alb_arn_suffix   = module.alb.alb_arn_suffix
  target_group_arn = module.compute.target_group_arn
  project_name     = var.project_name
  environment      = var.environment
  tags             = local.common_tags
}
