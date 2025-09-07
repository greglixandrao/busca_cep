# Project Configuration
variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "busca-cep"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# AWS Configuration
variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-west-2"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones para usar"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# ECS Configuration
variable "backend_desired_count" {
  description = "Número desejado de tasks do backend"
  type        = number
  default     = 1
}

variable "frontend_desired_count" {
  description = "Número desejado de tasks do frontend"
  type        = number
  default     = 1
}

variable "backend_cpu" {
  description = "CPU para o container backend"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memória para o container backend"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU para o container frontend"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memória para o container frontend"
  type        = number
  default     = 512
}

# Domain Configuration (opcional)
variable "domain_name" {
  description = "Nome do domínio (opcional)"
  type        = string
  default     = ""
}

variable "create_ssl_certificate" {
  description = "Criar certificado SSL/TLS"
  type        = bool
  default     = false
}

# Scaling Configuration
variable "enable_auto_scaling" {
  description = "Habilitar auto scaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Capacidade mínima para auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Capacidade máxima para auto scaling"
  type        = number
  default     = 10
}

# Monitoring Configuration
variable "enable_container_insights" {
  description = "Habilitar Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}

# Cost Optimization
variable "enable_fargate_spot" {
  description = "Usar Fargate Spot para reduzir custos"
  type        = bool
  default     = false
}

# Tags
variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default = {
    Project     = "BuscaCEP"
    ManagedBy   = "Terraform"
    Owner       = "greglixandrao"
    Application = "busca-cep"
  }
}
