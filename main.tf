terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.45.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  greeting = "Hello test, ${var.name} from ${data.aws_caller_identity.current.account_id}"
}
