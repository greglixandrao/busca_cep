# 🚀 Deploy AWS ECS - Busca CEP

Guia completo para deploy da aplicação Busca CEP na AWS usando ECS, Terraform e GitHub Actions.

## 📋 Índice

- [Pré-requisitos](#-pré-requisitos)
- [Configuração Inicial](#-configuração-inicial)
- [Deploy Manual](#-deploy-manual)
- [Deploy Automatizado (GitHub Actions)](#-deploy-automatizado-github-actions)
- [Monitoramento](#-monitoramento)
- [Troubleshooting](#-troubleshooting)
- [Custos Estimados](#-custos-estimados)
- [Cleanup](#-cleanup)

## 🔧 Pré-requisitos

### Software Necessário
- **AWS CLI** v2.x - [Instalar](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform** v1.0+ - [Instalar](https://terraform.io/downloads)
- **Docker** - [Instalar](https://docs.docker.com/get-docker/)
- **Git** - Para controle de versão

### Conta AWS
- Conta AWS ativa
- Usuário IAM com permissões administrativas
- AWS CLI configurado (`aws configure`)

### Permissões IAM Necessárias
O usuário precisa das seguintes permissões:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "ecr:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "iam:*",
                "logs:*",
                "application-autoscaling:*"
            ],
            "Resource": "*"
        }
    ]
}
```

## ⚙️ Configuração Inicial

### 1. Configurar AWS CLI

```bash
aws configure
```

Insira:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `us-west-2`
- Default output format: `json`

### 2. Verificar Configuração

```bash
aws sts get-caller-identity
```

### 3. Clonar Repositório

```bash
git clone <seu-repositorio>
cd busca_cep
```

## 🚀 Deploy Manual

### Opção 1: Script Automatizado (Recomendado)

```bash
./scripts/deploy.sh
```

O script irá:
1. ✅ Verificar dependências
2. ✅ Configurar Terraform
3. ✅ Criar infraestrutura AWS
4. ✅ Build e push das imagens Docker
5. ✅ Deploy dos serviços ECS

### Opção 2: Deploy Passo a Passo

#### 1. Inicializar Terraform

```bash
cd aws/terraform
terraform init
```

#### 2. Planejar Infraestrutura

```bash
terraform plan -out=tfplan
```

#### 3. Aplicar Infraestrutura

```bash
terraform apply tfplan
```

#### 4. Obter URLs dos Repositórios ECR

```bash
ECR_BACKEND=$(terraform output -raw backend_ecr_repository_url)
ECR_FRONTEND=$(terraform output -raw frontend_ecr_repository_url)
echo "Backend ECR: $ECR_BACKEND"
echo "Frontend ECR: $ECR_FRONTEND"
```

#### 5. Build e Push das Imagens

```bash
# Login no ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_BACKEND

# Backend
cd ../../backend
docker build -t $ECR_BACKEND:latest .
docker push $ECR_BACKEND:latest

# Frontend
cd ../front-end
docker build -t $ECR_FRONTEND:latest .
docker push $ECR_FRONTEND:latest
```

#### 6. Atualizar Serviços ECS

```bash
aws ecs update-service --cluster busca-cep-cluster --service busca-cep-backend-service --force-new-deployment --region us-west-2
aws ecs update-service --cluster busca-cep-cluster --service busca-cep-frontend-service --force-new-deployment --region us-west-2
```

## 🤖 Deploy Automatizado (GitHub Actions)

### 1. Configurar Secrets no GitHub

No repositório GitHub, vá em **Settings > Secrets and variables > Actions** e adicione:

| Secret | Descrição | Exemplo |
|--------|-----------|---------|
| `AWS_ACCESS_KEY_ID` | ID da chave de acesso AWS | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta AWS | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY` |

### 2. Configurar Task Definitions

Atualize os arquivos `aws/ecs/*.json` com seu Account ID:

```bash
# Obter Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $AWS_ACCOUNT_ID"

# Substituir nos arquivos
sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" aws/ecs/backend-task-definition.json
sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" aws/ecs/frontend-task-definition.json
```

### 3. Push para GitHub

```bash
git add .
git commit -m "feat: add AWS ECS deployment pipeline"
git push origin main
```

A pipeline será executada automaticamente!

### 4. Acompanhar Deploy

- Vá para **Actions** no GitHub
- Acompanhe o progresso do workflow
- Verifique logs em caso de erro

## 📊 Monitoramento

### CloudWatch Logs

```bash
# Logs do Backend
aws logs tail /ecs/busca-cep-backend --follow --region us-west-2

# Logs do Frontend  
aws logs tail /ecs/busca-cep-frontend --follow --region us-west-2
```

### Status dos Serviços ECS

```bash
aws ecs describe-services \
    --cluster busca-cep-cluster \
    --services busca-cep-backend-service busca-cep-frontend-service \
    --region us-west-2
```

### Métricas de Performance

```bash
# CPU e Memória dos serviços
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=busca-cep-backend-service Name=ClusterName,Value=busca-cep-cluster \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average \
    --region us-west-2
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Erro de Permissões

```
Error: AccessDenied: User is not authorized to perform...
```

**Solução**: Verificar permissões IAM do usuário.

#### 2. Task não inicia

```bash
# Verificar eventos da task
aws ecs describe-tasks \
    --cluster busca-cep-cluster \
    --tasks $(aws ecs list-tasks --cluster busca-cep-cluster --service-name busca-cep-backend-service --query 'taskArns[0]' --output text) \
    --region us-west-2
```

#### 3. Load Balancer não responde

```bash
# Verificar health checks
aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups --names busca-cep-backend-tg --query 'TargetGroups[0].TargetGroupArn' --output text --region us-west-2) \
    --region us-west-2
```

#### 4. Imagens não encontradas

```bash
# Verificar repositórios ECR
aws ecr describe-repositories --region us-west-2

# Verificar imagens
aws ecr list-images --repository-name busca-cep-backend --region us-west-2
```

### Comandos Úteis

```bash
# Reiniciar serviço
aws ecs update-service --cluster busca-cep-cluster --service busca-cep-backend-service --force-new-deployment --region us-west-2

# Escalar serviço
aws ecs update-service --cluster busca-cep-cluster --service busca-cep-backend-service --desired-count 2 --region us-west-2

# Ver logs em tempo real
aws logs tail /ecs/busca-cep-backend --follow --region us-west-2 --filter-pattern "ERROR"
```

## 💰 Custos Estimados

### Recursos Criados

| Recurso | Quantidade | Custo Mensal (USD) |
|---------|------------|-------------------|
| **ECS Fargate** (0.25 vCPU, 0.5GB) | 2 tasks | ~$15 |
| **Application Load Balancer** | 1 | ~$18 |
| **NAT Gateway** | 2 | ~$64 |
| **CloudWatch Logs** (1GB/mês) | - | ~$1 |
| **ECR Storage** (1GB) | - | ~$0.10 |
| **Data Transfer** | ~10GB | ~$1 |

**Total Estimado: ~$100/mês**

### Otimização de Custos

1. **Usar Fargate Spot** (50% desconto):
   ```bash
   # No terraform/variables.tf
   enable_fargate_spot = true
   ```

2. **Remover NAT Gateways** (para dev):
   - Tasks em subnets públicas
   - Não recomendado para produção

3. **Reduzir retenção de logs**:
   ```bash
   # No terraform/variables.tf
   log_retention_days = 7
   ```

## 🧹 Cleanup

### Destruir Infraestrutura

```bash
# Script automatizado (CUIDADO!)
./scripts/destroy.sh

# Ou manual
cd aws/terraform
terraform destroy
```

### Verificar Recursos Removidos

```bash
# Verificar se ainda há recursos
aws elbv2 describe-load-balancers --region us-west-2
aws ecs describe-clusters --region us-west-2  
aws ecr describe-repositories --region us-west-2
```

## 🎯 Próximos Passos

1. **Configurar Domínio Personalizado**
2. **Implementar HTTPS/SSL**
3. **Configurar Auto Scaling**
4. **Adicionar Monitoramento com Prometheus**
5. **Implementar Blue/Green Deployment**

## 📞 Suporte

- 📧 **Issues**: [GitHub Issues](https://github.com/seu-usuario/busca-cep/issues)
- 📚 **Documentação AWS**: [ECS Documentation](https://docs.aws.amazon.com/ecs/)
- 🔧 **Terraform**: [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**⚠️ Importante**: Sempre monitore os custos no AWS Cost Explorer e configure billing alerts!
