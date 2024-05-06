output "openapi_spec_json" {
  value       = module.apigateway.openapi_spec_json
  description = "The OpenAPI specification (in JSON) used to configure the APIGateway"
}

output "stage_arn" {
  value       = module.apigateway.stage_arn
  description = "ARN of the APIGateway stage"
}