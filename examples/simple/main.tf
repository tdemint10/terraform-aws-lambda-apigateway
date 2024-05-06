terraform {
  required_version = "~> 1.8"
}

# trivy:ignore:AVD-AWS-0057: Not needed for example
# trivy:ignore:AVD-AWS-0066: Tracing not needed for example
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.6"

  function_name = "example-lambda"
  description   = "Example lambda function"
  handler       = "handlers.handle"
  runtime       = "python3.10"

  source_path = "./src"
}

# trivy:ignore:AVD-AWS-0190: Caching not needed for example
module "apigateway" {
  source = "../.."

  service = "MyService"

  endpoints = {
    "GET /v1/greeting" : {
      lambda = {
        name       = module.lambda_function.lambda_function_name
        invoke_arn = module.lambda_function.lambda_function_invoke_arn
      }
    }
  }
}