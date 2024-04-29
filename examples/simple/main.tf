terraform {
  required_version = "~> 1.8"
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws@7.2.6"

  function_name = "example-lambda"
  description   = "Example lambda function"
  handler       = "src.handlers.handle"
  runtime       = "python3.10"

  source_path = "./"
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
        name       = module.lambda_function.lambda_function_name
        invoke_arn = module.lambda_function.lambda_function_invoke_arn
      }
    }
  }
}