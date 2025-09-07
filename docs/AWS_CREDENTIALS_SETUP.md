# 🔐 Configuração de Credenciais AWS para GitHub Actions

## Passo 1: Criar Usuário IAM

1. Acesse o **AWS Console** → **IAM**
2. Clique em **Users** → **Create user**
3. Nome do usuário: `busca-cep-github-actions`
4. **Access type**: Programmatic access
5. **Permissions**: Attach policies directly
6. Adicione as seguintes policies:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonVPCFullAccess`
   - `AmazonEC2FullAccess`
   - `ElasticLoadBalancingFullAccess`
   - `IAMFullAccess`
   - `CloudWatchFullAccess`
   - `ApplicationAutoScalingFullAccess`

## Passo 2: Criar Access Key

1. Selecione o usuário criado
2. Vá para **Security credentials**
3. Clique em **Create access key**
4. Selecione **CLI**
5. Copie o **Access Key ID** e **Secret Access Key**

## Passo 3: Configurar no GitHub

1. No seu repositório GitHub, vá para **Settings**
2. Clique em **Secrets and variables** → **Actions**
3. Clique em **New repository secret**
4. Adicione:
   - **Nome**: `AWS_ACCESS_KEY_ID`
   - **Valor**: [seu access key id]
5. Adicione outro secret:
   - **Nome**: `AWS_SECRET_ACCESS_KEY`
   - **Valor**: [seu secret access key]

## ⚠️ Importante

- **NUNCA** commit essas credenciais no código
- Use apenas para CI/CD automatizado
- Considere usar AWS IAM Roles for GitHub Actions (mais seguro)
- Monitore o uso das credenciais regularmente

## 🔒 Política IAM Personalizada (Mais Restritiva)

Para maior segurança, você pode criar uma política personalizada com apenas as permissões necessárias:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "ecr:*",
                "ec2:CreateVpc",
                "ec2:CreateSubnet",
                "ec2:CreateInternetGateway",
                "ec2:CreateRouteTable",
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeAvailabilityZones",
                "elasticloadbalancing:*",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:GetRole",
                "iam:PassRole",
                "logs:CreateLogGroup",
                "logs:PutRetentionPolicy",
                "application-autoscaling:*"
            ],
            "Resource": "*"
        }
    ]
}
```
