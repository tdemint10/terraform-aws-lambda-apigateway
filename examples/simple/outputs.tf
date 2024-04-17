output "greeting" {
  value       = module.apigateway.greeting.value
  description = "A standard greeting"
}