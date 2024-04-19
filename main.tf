terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.45.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.3"
    }
  }
}

data "aws_caller_identity" "current" {}
