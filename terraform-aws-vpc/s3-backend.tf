# terraform {
#   required_providers {
#     aws = {
#         source = "hashicorp/aws"
#         version = ">=4.0"
#     }
#   }

#     backend "s3" {
#       bucket = "aurally-tf-bucket"
#       key = "state/terraform.tfstate"
#       region = "us-east-1"
#       encrypt = true
#       dynamodb_table = "terraform-backend-lock"
#     }
# }

# provider "aws" {
#   default_tags {
#     tags = {
#       Environment = "Terraform"
#       Name = "tag"
#     }
#   }
# }