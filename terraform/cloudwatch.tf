resource "aws_cloudwatch_log_group" "lambda_auth_lg" {
  name              = "/aws/lambda/ApiGatewayAuthenticator"
  retention_in_days = 30
  skip_destroy      = false
  tags = {
    Name = "/aws/lambda/ApiGatewayAuthenticator"
  }
}