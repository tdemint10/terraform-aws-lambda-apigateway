terraform {
  required_version = "~> 1.8"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_string" "name" {
  length  = 10
  special = false
  upper   = false
}

module "apigateway" {
  source = "../.."
  name   = random_string.name.result
}