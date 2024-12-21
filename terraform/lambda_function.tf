data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda-function/lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "authorizer" {
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  function_name    = "ApiGatewayAuthenticator"
  filename         = "lambda_function.zip"
  package_type     = "Zip"
  role             = data.terraform_remote_state.geral.outputs.lab_role_arn
  source_code_hash = data.archive_file.lambda.output_base64sha256
  architectures    = ["x86_64", ]
  timeout          = 3
  skip_destroy     = false
  publish          = false

  tracing_config {
    mode = "PassThrough"
  }

  logging_config {
    log_group  = aws_cloudwatch_log_group.lambda_auth_lg.name
    log_format = "JSON"
  }

  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      COGNITO_USER_POOL_ID  = aws_cognito_user_pool.user_pool.id
      COGNITO_APP_CLIENT_ID = aws_cognito_user_pool_client.user_pool_client.id
    }
  }

  tags = {
    Name = "ApiGatewayAuthenticator"
  }
}
