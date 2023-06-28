locals {
  # dynamodb table
  connection = {
    name             = "IOTWSConnectionTable"
    billing_mode     = "PROVISIONED"
    read_capacity    = 1
    write_capacity   = 1
    hash_key         = "ConnectionID"
    ttl_enable       = true
    ttl_attribute    = "ExpirationTime"
  }

  # lambda
  ws_connection = {
    name            = "IotWSConnection"
    file            = "./lambda/connection/connection.zip"
    role            = aws_iam_role.connection.arn
    runtime         = "go1.x"
    handler         = "main"
    memory          = 128
    timeout         = 180
    concurrency     = 3
    env_vars        = {
      "API_GATEWAY_ENDPOINT" = "https://${aws_apigatewayv2_api.ws_messenger_api_gateway.id}.execute-api.${var.region}.amazonaws.com/${aws_apigatewayv2_stage.ws_messenger_api_stage.id}"
      "DYNAMODB_TABLE"       = aws_dynamodb_table.connection.id
    }
  }

  # api gateway
  api = {
    name = "iot_ws_api_gateway"
  }
}