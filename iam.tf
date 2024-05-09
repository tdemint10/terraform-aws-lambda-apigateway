resource "aws_iam_role" "apigateway_authorizers" {
  count = length(var.authorizers) == 0 ? 0 : 1

  name               = "${var.service}_authorizers"
  assume_role_policy = data.aws_iam_policy_document.apigateway_access.json
}

data "aws_iam_policy_document" "apigateway_access" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "apigateway_authorizers" {
  count = length(var.authorizers) == 0 ? 0 : 1

  name   = "${var.service}_authorizers"
  role   = aws_iam_role.apigateway_authorizers[0].id
  policy = data.aws_iam_policy_document.apigateway_authorizers.json
}

data "aws_iam_policy_document" "apigateway_authorizers" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [for authorizer in var.authorizers : authorizer.lambda.arn]
  }
}

resource "aws_iam_role" "api_gateway_account_role" {
  name               = "api-gateway-account-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_account_role_trust.json
}

data "aws_iam_policy_document" "api_gateway_account_role_trust" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name   = "api-gateway-cloudwatch-policy"
  role   = aws_iam_role.api_gateway_account_role.id
  policy = data.aws_iam_policy_document.api_gateway_cloudwatch_policy.json
}

# trivy:ignore:AVD-AWS-0057
data "aws_iam_policy_document" "api_gateway_cloudwatch_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_account_role.arn
}