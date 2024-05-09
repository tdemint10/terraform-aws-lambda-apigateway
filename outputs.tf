output "api_url" {
  value       = aws_api_gateway_deployment.this.invoke_url
  description = "The URL of the APIGateway deployment"
}

output "openapi_spec_json" {
  value       = aws_api_gateway_rest_api.this.body
  description = "The OpenAPI specification (in JSON) used to configure the APIGateway"
}

output "stage_arn" {
  value       = aws_api_gateway_stage.this.arn
  description = "ARN of the APIGateway stage"
}