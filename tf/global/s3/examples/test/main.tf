terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "s3" {
  source      = "../../../s3"
  bucket_name = "a50-avpn-test"
  bucket_key  = "test/s3/terraform.tfstate"
  lock_table  = "avpn-test"
}

output "s3_bucket_arn" {
  value       = module.s3.s3_bucket_arn
  description = "aws s3 bucket arn"
}

output "s3_bucket_key" {
  description = "TF state path"
  value       = module.s3.s3_bucket_key
}

output "dynamodb_table_name" {
  value       = module.s3.dynamodb_table_name
  description = "dynamodb table"
}


