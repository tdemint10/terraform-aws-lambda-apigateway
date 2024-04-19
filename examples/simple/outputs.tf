output "apigateway_domain_name" {
  value       = module.apigateway.apigateway_domain_name
  description = "Regional domain name of the APIGateway, for use with custom DNS records"
}

output "apigateway_domain_zone" {
  value       = module.apigateway.apigateway_domain_zone
  description = "Regional hosted zone ID of the APIGateway's domain, for use with custom DNS records"
}

output "openapi_spec_json" {
  value       = module.apigateway.openapi_spec_json
  description = "The OpenAPI specification (in JSON) used to configure the APIGateway"
}

output "openapi_spec_yaml" {
  value       = module.apigateway.openapi_spec_yaml
  description = "The OpenAPI specification (in YAML) used to configure the APIGateway"
}

output "stage_arn" {
  value       = module.apigateway.stage_arn
  description = "ARN of the APIGateway stage"
}