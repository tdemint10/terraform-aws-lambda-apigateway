"""Enrich an OpenAPI specification with APIGateway configuration.

APIGateway resources can be managed by uploading an OpenAPI specification. This
script parses an existing JSON spec (or creates a new one), then amends it
with the appropriate APIGateway extensions to OpenAPI. These will configure
Lambda function integrations, authorizer configuration, CORS settings, and
request validation.

Input & out are configured to work with Terraform's external data resource: as
JSON objects passed via stdin and stdout. It can be invoked via Terraform like
so:

    ```hcl
    data "external" "example" {
        program = ["python", "${path.module}/enrich_spec.py"]
        query = {
          authorizers = {
            for name, config in var.authorizers :
            name => {
              iam_role_arn          = aws_iam_role.apigateway_authorizers.arn
              result_ttl_in_seconds = config.result_ttl_in_seconds
              invoke_arn            = config.lambda.invoke_arn
              identity_validation   = config.identity_validation
            }
          }
          cors_configuration = jsonencode(var.cors_configuration)
          endpoints          = jsonencode(var.endpoints)
          service            = var.service
          specification      = jsonencode(yamldecode(var.api_specification))
          validate_requests  = jsonencode(var.validate_requests)
          version            = var.api_version
        }
    }

    resource "aws_api_gateway_rest_api" "example" {
      body = data.external.example.result.json_specification
      name = var.service
    }
    ```

Or via the command line for testing:

    ```shell
    $ echo "{\"service\": \"MyService\", \"version\": \"1.0.0\", \"endpoints\": \"{}\"}" \
    >   | python enrich_spec.py
    ```

Both will output a JSON object containing the finalized OpenAPI spec in JSON format:

    ```json
    {"json_specification": "{\"openapi\": \"3.0.3\"}"}
    ```

For information about APIGateway - OpenAPI extensions, see AWS documentation:
https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html
"""

import json
import sys
from collections import defaultdict
from typing import Tuple


def _read_input() -> Tuple[dict, dict, dict, defaultdict, str]:
    """Parse the JSON object on stdin and the referrenced OpenAPI specification file."""
    query = json.load(sys.stdin)
    authorizer_config = json.loads(query.get("authorizers", "{}"))
    endpoints = json.loads(query.get("endpoints", "{}"))
    cors_config = json.loads(query.get("cors_configuration", "{}"))
    if spec := query.get("specification"):
        spec = defaultdict(dict, json.loads(spec))
    else:
        spec = defaultdict(
            dict,
            {
                "openapi": "3.0.3",
                "info": {
                    "title": query["service"],
                    "version": query["version"],
                },
                "paths": defaultdict(lambda: defaultdict(dict)),
            },
        )
    return (
        authorizer_config,
        cors_config,
        endpoints,
        spec,
        query.get("validation", "NONE"),
    )


def _amend_spec(
    spec: defaultdict,
    endpoints: dict,
    authorizers_config: dict,
    cors_config: dict,
    validation: str,
) -> defaultdict:
    """Add APIGateway-OpenAPI extensions to the OpenAPI spec."""
    allow_headers = ",".join(cors_config.get("allow_headers", ""))
    allow_origins = ",".join(cors_config.get("allow_origins", ""))

    # Create authorizers at the top-level
    security_schemes = spec["components"].get("securitySchemes", {})
    security_schemes.update(
        {
            name: {
                "type": "apiKey",
                "name": "Authorization",
                "in": "header",
                "x-amazon-apigateway-authorizer": {
                    "type": "token",
                    "identityValidationExpression": config["identity_validation"],
                    "authorizerUri": config["invoke_arn"],
                    "authorizerCredentials": config["iam_role_arn"],
                    "authorizerResultTtlInSeconds": config["result_ttl_in_seconds"],
                },
                "x-amazon-apigateway-authtype": "custom",
            }
            for name, config in authorizers_config.items()
        }
    )
    spec["components"]["securitySchemes"] = security_schemes

    # Create validators at the top-level
    spec["x-amazon-apigateway-request-validators"].update(
        {
            "NONE": {"validateRequestBody": False, "validateRequestParameters": False},
            "PARAMS": {"validateRequestBody": False, "validateRequestParameters": True},
            "BODY": {"validateRequestBody": True, "validateRequestParameters": False},
            "FULL": {"validateRequestBody": True, "validateRequestParameters": True},
        }
    )
    if validation != "NONE":
        spec["x-amazon-apigateway-request-validator"] = validation

    # Amend individual endpoints
    for endpoint, config in endpoints.items():
        # Configure Lambda integration
        apigateway_spec = {
            "x-amazon-apigateway-integration": {
                "httpMethod": "POST",
                "payloadFormatVersion": config["payload_format_version"],
                "timeoutInMillis": config["timeout_milliseconds"],
                "type": "AWS_PROXY",
                "uri": config["lambda"]["invoke_arn"],
            }
        }
        if authorizer := config["authorizer_name"]:
            apigateway_spec["security"] = [{authorizer: []}]
        if validation := config["validation"]:
            apigateway_spec["x-amazon-apigateway-request-validator"] = validation

        method, path = endpoint.split()
        spec["paths"][path][method.lower()] |= apigateway_spec

        # Add CORS support
        allow_methods = ",".join(
            method.upper() for method in spec["paths"][path].keys()
        )
        cors_headers = {
            "Access-Control-Allow-Headers": f"'{allow_headers}'",
            "Access-Control-Allow-Methods": f"'{allow_methods}'",
            "Access-Control-Allow-Origin": f"'{allow_origins}'",
        }
        spec["paths"][path]["options"] = {
            "summary": "CORS support",
            "responses": {
                200: {
                    "headers": {
                        header: {"schema": {"type": "string"}}
                        for header in cors_headers.keys()
                    },
                    "content": {},
                },
            },
            "x-amazon-apigateway-integration": {
                "type": "MOCK",
                "requestTemplates": {
                    "application/json": json.dumps({"statusCode": 200}),
                },
                "responses": {
                    "default": {
                        "statusCode": "200",
                        "responseParameters": {
                            f"method.response.header.{header}": values
                            for header, values in cors_headers.items()
                        },
                        "responseTemplates": {"application/json": json.dumps({})},
                    }
                },
            },
        }
    return spec


if __name__ == "__main__":
    try:
        authorizers_config, cors_config, endpoints, spec, validation = _read_input()
    except (
        json.JSONDecodeError,
        KeyError,
        OSError,
        TypeError,
        json.JSONDecodeError,
    ) as error:
        print(f"Failed to read input - {error}", file=sys.stderr)
        exit(1)

    try:
        spec = _amend_spec(spec, endpoints, authorizers_config, cors_config, validation)
    except KeyError as error:
        print(f"Failed to modify OpenAPI specification - {error}", file=sys.stderr)
        exit(2)

    try:
        json.dump({"json_specification": json.dumps(spec)}, sys.stdout, indent=2)
        sys.stdout.write("\n")
    except (OSError, TypeError, ValueError) as error:
        print(f"Failed to write output - {error}", file=sys.stderr)
        exit(3)

    exit(0)
