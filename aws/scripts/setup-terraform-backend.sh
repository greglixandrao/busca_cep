#!/bin/bash

# Script para configurar o backend remoto do Terraform
# Cria bucket S3 com versionamento e criptografia

set -e

# Configurações
PROJECT_NAME="busca-cep"
AWS_REGION="us-west-2"
BUCKET_NAME="${PROJECT_NAME}-terraform-state-$(date +%s)"

echo "🚀 Configurando backend remoto do Terraform..."
echo "📦 Bucket S3: $BUCKET_NAME"
echo "🌎 Região: $AWS_REGION"
echo ""

# Verificar se AWS CLI está configurado
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI não está configurado. Execute 'aws configure' primeiro."
    exit 1
fi

# Obter ID da conta AWS
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🏢 Account ID: $AWS_ACCOUNT_ID"
echo ""

# Criar bucket S3 para o state
echo "📦 Criando bucket S3..."
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
    echo "⚠️  Bucket $BUCKET_NAME já existe"
else
    aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION"
    echo "✅ Bucket criado: $BUCKET_NAME"
fi

# Habilitar versionamento
echo "📝 Habilitando versionamento..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Habilitar criptografia
echo "🔒 Habilitando criptografia..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }
        ]
    }'

# Bloquear acesso público
echo "🛡️  Bloqueando acesso público..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Configurar lifecycle policy para otimizar custos
echo "♻️  Configurando lifecycle policy..."
aws s3api put-bucket-lifecycle-configuration \
    --bucket "$BUCKET_NAME" \
    --lifecycle-configuration '{
        "Rules": [
            {
                "ID": "OptimizeTerraformState",
                "Status": "Enabled",
                "Filter": {"Prefix": "infrastructure/"},
                "Transitions": [
                    {
                        "Days": 30,
                        "StorageClass": "STANDARD_IA"
                    },
                    {
                        "Days": 90,
                        "StorageClass": "GLACIER"
                    }
                ],
                "NoncurrentVersionTransitions": [
                    {
                        "NoncurrentDays": 7,
                        "StorageClass": "STANDARD_IA"
                    },
                    {
                        "NoncurrentDays": 30,
                        "StorageClass": "GLACIER"
                    }
                ],
                "NoncurrentVersionExpiration": {
                    "NoncurrentDays": 365
                }
            }
        ]
    }'

echo ""
echo "🎉 Backend remoto configurado com sucesso!"
echo ""
echo "📋 Configuração para o Terraform:"
echo "================================"
cat << EOF
terraform {
  backend "s3" {
    bucket  = "$BUCKET_NAME"
    key     = "infrastructure/terraform.tfstate"
    region  = "$AWS_REGION"
    encrypt = true
  }
}
EOF

echo ""
echo "💾 Salvando configuração em terraform-backend.conf..."
cat << EOF > terraform-backend.conf
bucket  = "$BUCKET_NAME"
key     = "infrastructure/terraform.tfstate"
region  = "$AWS_REGION"
encrypt = true
EOF

echo ""
echo "🚀 Para usar, execute:"
echo "cd aws/terraform"
echo "terraform init -backend-config=../scripts/terraform-backend.conf"
echo ""
echo "🔑 Secret do GitHub para adicionar:"
echo "TERRAFORM_S3_BUCKET=$BUCKET_NAME"
echo ""
echo "📝 Nome do bucket para usar no workflow:"
echo "$BUCKET_NAME"
