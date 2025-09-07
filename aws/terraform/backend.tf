# Terraform Backend Configuration
# This file can be used to configure remote state storage in S3 for production
# Currently using local backend since main.tf already has the provider configuration

# For production, you can enable S3 backend by adding this to main.tf:
# terraform {
#   backend "s3" {
#     bucket         = "busca-cep-terraform-state"
#     key            = "infrastructure/terraform.tfstate"
#     region         = "us-west-2"
#     encrypt        = true
#     dynamodb_table = "busca-cep-terraform-locks"
#   }
# }

# Note: Provider and data sources are already configured in main.tf
