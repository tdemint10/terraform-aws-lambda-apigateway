resource "aws_api_gateway_rest_api" "this" {
  api_key_source = "AUTHORIZER"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = var.service
      version = "1.0"
    }
    paths = {
      "/v1/greeting" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "AWS"
            uri        = values(var.endpoints)[0].lambda.invoke_arn

            responses = {
              default = {
                statusCode = "200"
              }
            }
          }

          responses = {
            200 = {
              description = "Success"
            }
          }
        }
      }
    }
  })
  disable_execute_api_endpoint = true
  name                         = var.service

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.this.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  log_format = <<-EOT
      {
        "requestId": "$context.requestId",
        "extendedRequestId": "$context.extendedRequestId",
        "ip": "$context.identity.sourceIp",
        "caller": "$context.identity.caller",
        "user": "$context.identity.user",
        "requestTime": "$context.requestTime",
        "httpMethod": "$context.httpMethod",
        "resourcePath": "$context.resourcePath",
        "status": "$context.status",
        "protocol": "$context.protocol",
        "responseLength": "$context.responseLength"
      }
    EOT
}

resource "aws_api_gateway_stage" "this" {
  depends_on = [aws_cloudwatch_log_group.api_access]

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "default"

  cache_cluster_enabled = var.cache_size == "0" ? false : true
  cache_cluster_size    = var.cache_size == "0" ? null : var.cache_size
  xray_tracing_enabled  = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access.arn
    format          = replace(local.log_format, "\n", "")
  }
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/default"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_api_gateway_method_settings" "overrides" {
  for_each = var.endpoints

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = trimprefix(join("/", reverse(split(" ", each.key))), "/")

  settings {
    data_trace_enabled   = each.value.data_trace_enabled
    cache_ttl_in_seconds = each.value.cache_ttl_in_seconds
    cache_data_encrypted = each.value.cache_data_encrypted
    caching_enabled      = each.value.cache_enabled
    metrics_enabled      = each.value.metrics_enabled

    logging_level                              = each.value.logging_level
    require_authorization_for_cache_control    = each.value.cache_control_authorized
    throttling_burst_limit                     = each.value.throttling_burst_limit
    throttling_rate_limit                      = each.value.throttling_rate_limit
    unauthorized_cache_control_header_strategy = each.value.cache_control_response_strategy
  }
}