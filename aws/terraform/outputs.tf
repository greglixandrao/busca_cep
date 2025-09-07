# VPC Outputs
output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

# Load Balancer Outputs
output "load_balancer_dns" {
  description = "DNS do Load Balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID do Load Balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN do Load Balancer"
  value       = aws_lb.main.arn
}

# Application URLs
output "application_url" {
  description = "URL principal da aplicação"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_api_url" {
  description = "URL da API backend"
  value       = "http://${aws_lb.main.dns_name}/api"
}

output "api_docs_url" {
  description = "URL da documentação da API"
  value       = "http://${aws_lb.main.dns_name}/docs"
}

# ECR Outputs
output "backend_ecr_repository_url" {
  description = "URL do repositório ECR do backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_url" {
  description = "URL do repositório ECR do frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS"
  value       = aws_ecs_cluster.main.arn
}

output "backend_service_name" {
  description = "Nome do serviço ECS do backend"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Nome do serviço ECS do frontend"
  value       = aws_ecs_service.frontend.name
}

# Security Groups
output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "backend_security_group_id" {
  description = "ID do Security Group do backend"
  value       = aws_security_group.ecs_backend.id
}

output "frontend_security_group_id" {
  description = "ID do Security Group do frontend"
  value       = aws_security_group.ecs_frontend.id
}

# CloudWatch Logs
output "backend_log_group" {
  description = "Nome do Log Group do backend"
  value       = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group" {
  description = "Nome do Log Group do frontend"
  value       = aws_cloudwatch_log_group.frontend.name
}

# IAM Roles
output "ecs_task_execution_role_arn" {
  description = "ARN da role de execução das tasks ECS"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN da role das tasks ECS"
  value       = aws_iam_role.ecs_task_role.arn
}

# AWS Account Info
output "aws_account_id" {
  description = "ID da conta AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Região AWS utilizada"
  value       = var.aws_region
}

# Deployment Information
output "deployment_info" {
  description = "Informações importantes para deployment"
  value = {
    application_url     = "http://${aws_lb.main.dns_name}"
    backend_api_url     = "http://${aws_lb.main.dns_name}/api"
    api_docs_url       = "http://${aws_lb.main.dns_name}/docs"
    ecs_cluster        = aws_ecs_cluster.main.name
    backend_ecr_repo   = aws_ecr_repository.backend.repository_url
    frontend_ecr_repo  = aws_ecr_repository.frontend.repository_url
    aws_region         = var.aws_region
    aws_account_id     = data.aws_caller_identity.current.account_id
  }
}
