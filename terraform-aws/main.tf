
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Project     = "Enterprise-AI-Platform"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  }
}

# Retrieve AWS Account Information
data "aws_caller_identity" "current" {}

# Retrieve available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Display AWS account information
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = "ap-southeast-1"
}

output "available_availability_zones" {
  value = data.aws_availability_zones.available.names
}
