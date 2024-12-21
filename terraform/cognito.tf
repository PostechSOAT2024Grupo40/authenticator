resource "aws_cognito_user_pool" "user_pool" {
  name = "ambrosia-user-pool"

  schema {
    attribute_data_type = "String"
    name                = "custom:cpf"
    mutable             = false
    required            = true
  }
}


resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = "ambrosia-client"
}
