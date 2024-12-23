resource "aws_apigatewayv2_api" "api_gateway" {
  name                         = "ambrosia-api-gateway"
  protocol_type                = "HTTP"
  api_key_selection_expression = "$request.header.x-api-key"
  route_selection_expression   = "$request.method $request.path"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age           = 0
  }

  tags = {
    Name = "ambrosia-api-gateway"
  }
}

resource "aws_apigatewayv2_integration" "alb_integration" {
  depends_on         = [aws_apigatewayv2_api.api_gateway]
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  connection_type    = "INTERNET"
  integration_method = "ANY"
  integration_uri    = "http://${data.terraform_remote_state.geral.outputs.alb_dns}"
}


resource "aws_apigatewayv2_authorizer" "authorizer" {
  depends_on                        = [aws_apigatewayv2_api.api_gateway, aws_lambda_function.authorizer]
  name                              = "lambdaAuthenticator"
  api_id                            = aws_apigatewayv2_api.api_gateway.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  identity_sources                  = ["$request.header.Authorization", ]
}



locals {
  methods = ["POST", "PUT", "OPTIONS", "HEAD", "DELETE", "GET", "PATCH"]
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = toset(local.methods)

  authorization_type = each.value == "OPTIONS" || each.value == "HEAD" ? "NONE" : "CUSTOM"
  authorizer_id      = each.value == "OPTIONS" || each.value == "HEAD" ? null : aws_apigatewayv2_authorizer.authorizer.id
  api_id             = aws_apigatewayv2_api.api_gateway.id
  route_key          = "${each.value} /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}
