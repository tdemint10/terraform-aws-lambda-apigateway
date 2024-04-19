output "apigateway_domain_name" {
  value       = aws_api_gateway_domain_name.this.regional_domain_name
  description = "Regional domain name of the APIGateway, for use with custom DNS records"
}

output "apigateway_domain_zone" {
  value       = aws_api_gateway_domain_name.this.regional_zone_id
  description = "Regional hosted zone ID of the APIGateway's domain, for use with custom DNS records"
}

output "openapi_spec_json" {
  value       = aws_api_gateway_rest_api.this.body
  description = "The OpenAPI specification (in JSON) used to configure the APIGateway"
}

output "openapi_spec_yaml" {
  value       = yamlencode(jsondecode(data.external.enriched_specification.result.json_specification))
  description = "The OpenAPI specification (in YAML) used to configure the APIGateway"
}

output "stage_arn" {
  value       = aws_api_gateway_stage.this.arn
  description = "ARN of the APIGateway stage"
}