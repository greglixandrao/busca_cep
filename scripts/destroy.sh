#!/bin/bash

# Script para Destruir Infraestrutura Busca CEP
# ATENÇÃO: Este script remove TODA a infraestrutura AWS criada

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

# Confirmar destruição
confirm_destruction() {
    echo -e "${RED}⚠️  ATENÇÃO: OPERAÇÃO DESTRUTIVA ⚠️${NC}"
    echo
    echo "Este script irá:"
    echo "  ❌ Remover TODOS os recursos AWS"
    echo "  ❌ Deletar o cluster ECS"
    echo "  ❌ Remover Load Balancer e VPC"
    echo "  ❌ Deletar repositórios ECR (com imagens)"
    echo "  ❌ Remover logs do CloudWatch"
    echo
    log_warning "Esta operação NÃO pode ser desfeita!"
    echo
    
    read -p "Digite 'DESTROY' para confirmar a destruição completa: " confirmation
    
    if [[ $confirmation != "DESTROY" ]]; then
        log_info "Operação cancelada. Nenhum recurso foi removido."
        exit 0
    fi
}

# Verificar se Terraform está inicializado
check_terraform() {
    log_info "Verificando Terraform..."
    
    if [[ ! -d "$TERRAFORM_DIR/.terraform" ]]; then
        log_error "Terraform não inicializado. Execute: terraform init no diretório $TERRAFORM_DIR"
        exit 1
    fi
    
    log_success "Terraform verificado"
}

# Parar serviços ECS antes da destruição
stop_ecs_services() {
    log_info "Parando serviços ECS..."
    
    # Verificar se o cluster existe
    if aws ecs describe-clusters --clusters "${PROJECT_NAME}-cluster" --region $AWS_REGION &> /dev/null; then
        log_info "Escalando serviços para 0..."
        
        aws ecs update-service \
            --cluster "${PROJECT_NAME}-cluster" \
            --service "${PROJECT_NAME}-backend-service" \
            --desired-count 0 \
            --region $AWS_REGION &> /dev/null || true
        
        aws ecs update-service \
            --cluster "${PROJECT_NAME}-cluster" \
            --service "${PROJECT_NAME}-frontend-service" \
            --desired-count 0 \
            --region $AWS_REGION &> /dev/null || true
        
        log_info "Aguardando parada dos serviços..."
        sleep 30
        
        log_success "Serviços ECS parados"
    else
        log_info "Cluster ECS não encontrado, pulando..."
    fi
}

# Esvaziar repositórios ECR
empty_ecr_repositories() {
    log_info "Esvaziando repositórios ECR..."
    
    # Backend repository
    if aws ecr describe-repositories --repository-names "${PROJECT_NAME}-backend" --region $AWS_REGION &> /dev/null; then
        log_info "Removendo imagens do repositório backend..."
        IMAGE_TAGS=$(aws ecr list-images --repository-name "${PROJECT_NAME}-backend" --region $AWS_REGION --query 'imageIds[*]' --output json)
        
        if [[ $IMAGE_TAGS != "[]" ]]; then
            aws ecr batch-delete-image \
                --repository-name "${PROJECT_NAME}-backend" \
                --image-ids "$IMAGE_TAGS" \
                --region $AWS_REGION &> /dev/null || true
        fi
    fi
    
    # Frontend repository
    if aws ecr describe-repositories --repository-names "${PROJECT_NAME}-frontend" --region $AWS_REGION &> /dev/null; then
        log_info "Removendo imagens do repositório frontend..."
        IMAGE_TAGS=$(aws ecr list-images --repository-name "${PROJECT_NAME}-frontend" --region $AWS_REGION --query 'imageIds[*]' --output json)
        
        if [[ $IMAGE_TAGS != "[]" ]]; then
            aws ecr batch-delete-image \
                --repository-name "${PROJECT_NAME}-frontend" \
                --image-ids "$IMAGE_TAGS" \
                --region $AWS_REGION &> /dev/null || true
        fi
    fi
    
    log_success "Repositórios ECR esvaziados"
}

# Executar terraform destroy
terraform_destroy() {
    log_info "Executando terraform destroy..."
    cd $TERRAFORM_DIR
    
    if ! terraform destroy -auto-approve; then
        log_error "Falha na destruição com Terraform"
        log_info "Tentando limpeza manual dos recursos restantes..."
        
        # Tentativa de limpeza manual
        manual_cleanup
    fi
    
    log_success "Terraform destroy concluído"
    cd - > /dev/null
}

# Limpeza manual em caso de falha do Terraform
manual_cleanup() {
    log_warning "Iniciando limpeza manual..."
    
    # Remover NAT Gateways manualmente se necessário
    log_info "Verificando NAT Gateways..."
    NAT_GWS=$(aws ec2 describe-nat-gateways \
        --filter "Name=tag:Project,Values=BuscaCEP" \
        --query 'NatGateways[?State==`available`].NatGatewayId' \
        --output text \
        --region $AWS_REGION)
    
    for nat_gw in $NAT_GWS; do
        if [[ -n $nat_gw ]]; then
            log_info "Removendo NAT Gateway: $nat_gw"
            aws ec2 delete-nat-gateway --nat-gateway-id $nat_gw --region $AWS_REGION || true
        fi
    done
    
    log_info "Limpeza manual concluída"
}

# Verificar recursos restantes
check_remaining_resources() {
    log_info "Verificando recursos restantes..."
    
    # Verificar ECS
    if aws ecs describe-clusters --clusters "${PROJECT_NAME}-cluster" --region $AWS_REGION &> /dev/null; then
        log_warning "Cluster ECS ainda existe"
    fi
    
    # Verificar ECR
    if aws ecr describe-repositories --repository-names "${PROJECT_NAME}-backend" --region $AWS_REGION &> /dev/null; then
        log_warning "Repositório ECR backend ainda existe"
    fi
    
    if aws ecr describe-repositories --repository-names "${PROJECT_NAME}-frontend" --region $AWS_REGION &> /dev/null; then
        log_warning "Repositório ECR frontend ainda existe"
    fi
    
    # Verificar Load Balancer
    if aws elbv2 describe-load-balancers --names "${PROJECT_NAME}-alb" --region $AWS_REGION &> /dev/null; then
        log_warning "Load Balancer ainda existe"
    fi
    
    log_info "Verificação de recursos concluída"
}

# Função principal
main() {
    echo -e "${RED}🗑️  Destruição da Infraestrutura Busca CEP${NC}"
    echo "============================================="
    echo
    
    confirm_destruction
    check_terraform
    stop_ecs_services
    empty_ecr_repositories
    terraform_destroy
    check_remaining_resources
    
    echo
    log_success "Destruição concluída!"
    echo
    log_info "Recursos que podem ter custos residuais:"
    echo "  - Elastic IPs não associados"
    echo "  - Snapshots de volumes"
    echo "  - Logs do CloudWatch (dependendo da retenção)"
    echo
    log_info "Verifique no console AWS se há recursos não removidos"
}

# Executar apenas se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
