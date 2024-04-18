terraform {
  required_version = "~> 1.8"
}

module "apigateway" {
  source = "../.."
  name   = "example"
}