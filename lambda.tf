resource "aws_lambda_permission" "apigateway_invoke_handlers" {
  for_each = var.endpoints

  function_name  = each.value.lambda.name
  action         = "lambda:InvokeFunction"
  statement_id   = "apigateway-access"
  principal      = "apigateway.amazonaws.com"
  source_arn     = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_lambda_permission" "apigateway_invoke_authorizers" {
  for_each = var.authorizers

  function_name  = each.value.lambda.name
  action         = "lambda:InvokeFunction"
  statement_id   = "apigateway-access"
  principal      = "apigateway.amazonaws.com"
  source_arn     = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  source_account = data.aws_caller_identity.current.account_id
}