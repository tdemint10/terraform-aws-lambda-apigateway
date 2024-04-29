terraform {
  required_version = "~> 1.8"
}

module "lambda_functions" {
  source   = "git@github.com:lamarmeigs/terraform-aws-pipenv-lambdas.git?ref=v1.1.1"
  packages = ["src"]
  runtime  = "python3.10"
  root     = "."
  service  = "example-service"
  functions = {
    GetGreeting = {
      handler = "src.handlers.get_greeting"
    }
  }
}

# trivy:ignore:AVD-AWS-0190: Caching not needed for example
module "apigateway" {
  source = "../.."

  domain_certificate_arn = "arn::MyServiceDomain"
  domain_name            = "MyServiceDomain"
  service                = "MyService"

  endpoints = {
    "GET /v1/greeting" : {
      lambda = {
        name       = module.lambda_functions.functions.GetGreeting.name
        invoke_arn = module.lambda_functions.functions.GetGreeting.invoke_arn
      }
    }
  }
}