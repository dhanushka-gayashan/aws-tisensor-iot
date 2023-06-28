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
      "API_GATEWAY_ENDPOINT" = "https://${aws_apigatewayv2_api.ws_iot.id}.execute-api.${var.region}.amazonaws.com/${aws_apigatewayv2_stage.ws_iot.id}"
      "DYNAMODB_TABLE"       = aws_dynamodb_table.connection.id
    }
  }

  # api gateway
  api = {
    name = "iot_ws_api_gateway"
  }

  # topic rule
  rule = {
    name        = "Lambda"
    description = "Iot Topic Rule for Lambda"
    enabled     = var.enable
    sql         = "SELECT pressure, temperature, humidity FROM 'aws/sensorTag'"
    sql_version = "2016-03-23"
  }
}