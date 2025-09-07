#!/bin/bash

# Script de Deploy da Aplicação Busca CEP
# Este script automatiza o processo de deploy na AWS

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
PROJECT_NAME="busca-cep"
AWS_REGION="us-west-2"
TERRAFORM_DIR="aws/terraform"

# Funções auxiliares
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI não encontrado. Instale: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform não encontrado. Instale: https://terraform.io/downloads"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker não encontrado. Instale: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    log_success "Todas as dependências estão instaladas"
}

# Verificar configuração AWS
check_aws_config() {
    log_info "Verificando configuração AWS..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI não configurado. Execute: aws configure"
        exit 1
    fi
    
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    log_success "AWS configurado. Account ID: $AWS_ACCOUNT_ID"
}

# Inicializar Terraform
terraform_init() {
    log_info "Inicializando Terraform..."
    cd $TERRAFORM_DIR
    
    if ! terraform init; then
        log_error "Falha ao inicializar Terraform"
        exit 1
    fi
    
    log_success "Terraform inicializado com sucesso"
    cd - > /dev/null
}

# Planejar infraestrutura
terraform_plan() {
    log_info "Planejando infraestrutura..."
    cd $TERRAFORM_DIR
    
    terraform plan -out=tfplan
    
    log_success "Plano do Terraform gerado"
    cd - > /dev/null
}

# Aplicar infraestrutura
terraform_apply() {
    log_info "Aplicando infraestrutura..."
    cd $TERRAFORM_DIR
    
    if ! terraform apply tfplan; then
        log_error "Falha ao aplicar infraestrutura"
        exit 1
    fi
    
    log_success "Infraestrutura aplicada com sucesso"
    cd - > /dev/null
}

# Obter outputs do Terraform
get_terraform_outputs() {
    log_info "Obtendo informações da infraestrutura..."
    cd $TERRAFORM_DIR
    
    ECR_BACKEND_REPO=$(terraform output -raw backend_ecr_repository_url)
    ECR_FRONTEND_REPO=$(terraform output -raw frontend_ecr_repository_url)
    ALB_DNS=$(terraform output -raw load_balancer_dns)
    
    log_success "Outputs obtidos:"
    echo "  Backend ECR: $ECR_BACKEND_REPO"
    echo "  Frontend ECR: $ECR_FRONTEND_REPO"
    echo "  Load Balancer: $ALB_DNS"
    
    cd - > /dev/null
}

# Build e push das imagens
build_and_push_images() {
    log_info "Fazendo login no ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BACKEND_REPO
    
    log_info "Construindo e enviando imagem do backend..."
    cd backend
    docker build -t $ECR_BACKEND_REPO:latest .
    docker push $ECR_BACKEND_REPO:latest
    cd ..
    
    log_info "Construindo e enviando imagem do frontend..."
    cd front-end
    docker build -t $ECR_FRONTEND_REPO:latest .
    docker push $ECR_FRONTEND_REPO:latest
    cd ..
    
    log_success "Imagens enviadas com sucesso"
}

# Atualizar serviços ECS
update_ecs_services() {
    log_info "Atualizando serviços ECS..."
    
    aws ecs update-service \
        --cluster "${PROJECT_NAME}-cluster" \
        --service "${PROJECT_NAME}-backend-service" \
        --force-new-deployment \
        --region $AWS_REGION
    
    aws ecs update-service \
        --cluster "${PROJECT_NAME}-cluster" \
        --service "${PROJECT_NAME}-frontend-service" \
        --force-new-deployment \
        --region $AWS_REGION
    
    log_success "Serviços ECS atualizados"
}

# Aguardar estabilização dos serviços
wait_for_deployment() {
    log_info "Aguardando estabilização dos serviços..."
    
    aws ecs wait services-stable \
        --cluster "${PROJECT_NAME}-cluster" \
        --services "${PROJECT_NAME}-backend-service" \
        --region $AWS_REGION
    
    aws ecs wait services-stable \
        --cluster "${PROJECT_NAME}-cluster" \
        --services "${PROJECT_NAME}-frontend-service" \
        --region $AWS_REGION
    
    log_success "Serviços estabilizados"
}

# Mostrar informações finais
show_final_info() {
    log_success "Deploy concluído com sucesso!"
    echo
    echo "🌐 Aplicação disponível em: http://$ALB_DNS"
    echo "🔧 API Backend: http://$ALB_DNS/api"
    echo "📚 Documentação: http://$ALB_DNS/docs"
    echo
    log_info "Para monitorar os serviços:"
    echo "aws ecs describe-services --cluster ${PROJECT_NAME}-cluster --services ${PROJECT_NAME}-backend-service ${PROJECT_NAME}-frontend-service --region $AWS_REGION"
}

# Função principal
main() {
    echo "🚀 Iniciando deploy da aplicação Busca CEP"
    echo "=========================================="
    
    check_dependencies
    check_aws_config
    terraform_init
    terraform_plan
    
    read -p "Deseja continuar com o deploy? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Deploy cancelado pelo usuário"
        exit 0
    fi
    
    terraform_apply
    get_terraform_outputs
    build_and_push_images
    update_ecs_services
    wait_for_deployment
    show_final_info
}

# Executar apenas se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
