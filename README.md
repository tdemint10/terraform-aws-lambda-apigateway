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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.44.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the user to greet | `string` | `"World"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_greeting"></a> [greeting](#output\_greeting) | A standard greeting |

## Resources

| Name | Type |
|------|------|
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
<<<<<<< HEAD
$ brew install pre-commit terraform-docs tflint trivy go
=======
$ brew install pre-commit tflint trivy go
>>>>>>> upstream/main
$ pre-commit install
```