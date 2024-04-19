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