terraform {
  required_version = "~> 1.8"
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
        name       = "Greeting"
        invoke_arn = "arn::GreetingLambda"
      }
    }
  }
}