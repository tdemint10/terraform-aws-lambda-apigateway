# terraform-aws-lambda-apigateway

This Terraform module manages APIGateway resources, producing an HTTP API whose
endpoints are provided by Lambda functions. Infrastructure management is split 
between Terraform resources and an uploaded OpenAPI specification, amended with
[APIGateway - OpenAPI extensions](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html). 

## Examples

### Basic usage:

```hcl
module "example" {
  source = "."
  name = "Alice"
}
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.45.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorizers"></a> [authorizers](#input\_authorizers) | Map of authorizer names to configuration objects | <pre>map(<br>    object({<br>      lambda                = object({ name = string, arn = string, invoke_arn = string })<br>      identity_validation   = optional(string, "^Bearer: .+$")<br>      result_ttl_in_seconds = optional(number, 300)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_cache_size"></a> [cache\_size](#input\_cache\_size) | Size of the cache in GB. Allowed values include `0`, `0.5`, `1.6`, `6.1`, `13.5`, `28.4`, `58.2`, `118`, and `237`. | `string` | `"0"` | no |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | Map of routes to configuration objects | <pre>map(<br>    object({<br>      lambda                          = object({ name = string, invoke_arn = string })<br>      authorizer_name                 = optional(string)<br>      cache_ttl_in_seconds            = optional(number, 5)<br>      cache_data_encrypted            = optional(bool, true)<br>      cache_enabled                   = optional(bool, false)<br>      cache_control_authorized        = optional(bool, true)<br>      cache_control_response_strategy = optional(string, "SUCCEED_WITH_RESPONSE_HEADER")<br>      data_trace_enabled              = optional(bool, true)<br>      description                     = optional(string)<br>      metrics_enabled                 = optional(bool, true)<br>      logging_level                   = optional(string, "ERROR")<br>      payload_format_version          = optional(string, "2.0")<br>      timeout_milliseconds            = optional(number, 29000)<br>      throttling_burst_limit          = optional(number, -1)<br>      throttling_rate_limit           = optional(number, -1)<br>      validation                      = optional(string)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key used to encrypt APIGateway access logs | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The number of days to retain APIGateway access logs in CloudWatch | `number` | `60` | no |
| <a name="input_service"></a> [service](#input\_service) | Name of the service | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | The URL of the APIGateway deployment |
| <a name="output_openapi_spec_json"></a> [openapi\_spec\_json](#output\_openapi\_spec\_json) | The OpenAPI specification (in JSON) used to configure the APIGateway |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | ARN of the APIGateway stage |
## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.api_gateway_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_method_settings.overrides](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_cloudwatch_log_group.api_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.api_gateway_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.apigateway_authorizers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.api_gateway_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.apigateway_authorizers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_permission.apigateway_invoke_authorizers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigateway_invoke_handlers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
<!-- END_TF_DOCS -->

## Contributing

This is intended as a thought exercise more than for actual distribution. If you care to fork it
to make your own modifications, have at it!

### Getting started

The module is intended for use in [Terraform](https://www.terraform.io/) configurations. Be sure
to install an appropriate version of the tool (see `main.tf`), preferably via something like
[`tfenv`](https://github.com/tfutils/tfenv).

On a mac, using [homebrew](https://brew.sh/):

```shell
$ brew install tfenv
$ tfenv install 1.8.0
$ tfenv use 1.8.0
```

### Validation

For convenience, this project includes [`pre-commit`](https://pre-commit.com) hooks that perform
validation on each commit, catching more egregious errors and ensuring
[style conventions](https://developer.hashicorp.com/terraform/language/syntax/style). They can
be installed via the following commands:

```shell
$ brew install pre-commit terraform-docs tflint trivy go
$ pre-commit install
```