#############
# IAM ROlES #
#############

# connection lambda
data "aws_iam_policy_document" "connection_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "connection_dynamodb" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.connection.arn]
  }
}

data "aws_iam_policy_document" "connection_api" {
  statement {
    effect  = "Allow"
    actions = [
      "execute-api:*",
    ]
    resources = [
      "${aws_apigatewayv2_stage.ws_messenger_api_stage.execution_arn}/*/*/*"
    ]
  }
}

data "aws_iam_policy_document" "connection_log" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "connection" {
  name               = "IotWSConnectionLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.connection_assume.json
}

resource "aws_iam_role_policy" "connection_dynamodb" {
  name   = "IotWSConnectionLambdaDynamodbPolicy"
  role   = aws_iam_role.connection.id
  policy = data.aws_iam_policy_document.connection_dynamodb.json
}

resource "aws_iam_role_policy" "connection_api" {
  name   = "IotWSConnectionLambdaApiPolicy"
  role   = aws_iam_role.connection.id
  policy = data.aws_iam_policy_document.connection_api.json
}

resource "aws_iam_role_policy" "connection_log" {
  name   = "IotWSConnectionLambdaLogPolicy"
  role   = aws_iam_role.connection.id
  policy = data.aws_iam_policy_document.connection_log.json
}

# api gateway
data "aws_iam_policy_document" "api_gateway_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "api_gateway_lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = [aws_lambda_function.connection.arn]
  }
}

data "aws_iam_policy_document" "api_gateway_logs" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "api_gateway" {
  name               = "IotWSAPIGatewayRole"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume.json
}

resource "aws_iam_role_policy" "api_gateway_lambda" {
  name   = "IotWSAPIGatewayLambdaPolicy"
  role   = aws_iam_role.api_gateway.id
  policy = data.aws_iam_policy_document.api_gateway_lambda.json
}

resource "aws_iam_role_policy" "api_gateway_log" {
  name   = "IotAPIGatewayLogPolicy"
  role   = aws_iam_role.api_gateway.id
  policy = data.aws_iam_policy_document.api_gateway_logs.json
}


######################
# RAW DYNAMODB TABLE #
######################

resource "aws_dynamodb_table" "connection" {
  name           = local.connection.name
  billing_mode     = local.connection.billing_mode
  read_capacity    = local.connection.read_capacity
  write_capacity   = local.connection.write_capacity
  hash_key         = local.connection.hash_key

  attribute {
    name = local.connection.hash_key
    type = "S"
  }

  ttl {
    enabled        = local.connection.ttl_enable
    attribute_name = local.connection.ttl_attribute
  }
}


##########
# LAMBDA #
##########

### connection ###
resource "aws_lambda_function" "connection" {
  function_name                  = local.ws_connection.name
  handler                        = local.ws_connection.handler
  runtime                        = local.ws_connection.runtime
  role                           = local.ws_connection.role
  filename                       = "${path.module}/${local.ws_connection.file}"
  source_code_hash               = filebase64sha256("${path.module}/${local.ws_connection.file}")
  memory_size                    = local.ws_connection.memory
  timeout                        = local.ws_connection.timeout
  reserved_concurrent_executions = local.ws_connection.concurrency

  environment {
    variables = local.ws_connection.env_vars
  }
}

resource "aws_cloudwatch_log_group" "connection" {
  name              = "/aws/lambda/${aws_lambda_function.connection.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "connection_invocation" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connection.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ws_messenger_api_gateway.execution_arn}/*/*"
}

### ito rule publisher ###
# TODO


###########################
# API GATEWAY CERTIFICATE #
###########################
# TODO


###############
# API GATEWAY #
###############

### api gateway ###
resource "aws_apigatewayv2_api" "ws_messenger_api_gateway" {
  name                       = local.api.name
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

# TODO - Refactor the code
### resource integration ###
resource "aws_apigatewayv2_integration" "ws_messenger_api_integration" {
  api_id                    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  integration_type          = "AWS_PROXY"
  integration_uri           = aws_lambda_function.connection.invoke_arn
  credentials_arn           = aws_iam_role.api_gateway.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_integration_response" "ws_messenger_api_integration_response" {
  api_id                   = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  integration_id           = aws_apigatewayv2_integration.ws_messenger_api_integration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route" "ws_messenger_api_default_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.ws_messenger_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_default_route_response" {
  api_id             = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_messenger_api_default_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_messenger_api_connect_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_messenger_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_connect_route_response" {
  api_id             = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_messenger_api_connect_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_messenger_api_disconnect_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_messenger_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_disconnect_route_response" {
  api_id             = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_messenger_api_disconnect_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_messenger_api_ping_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "PING"
  target    = "integrations/${aws_apigatewayv2_integration.ws_messenger_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_ping_route_response" {
  api_id             = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_messenger_api_ping_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_messenger_api_message_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "MESSAGE"
  target    = "integrations/${aws_apigatewayv2_integration.ws_messenger_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_message_route_response" {
  api_id             = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_messenger_api_message_route.id
  route_response_key = "$default"
}

# TODO - Refactor the code
### deployment ###
resource "aws_apigatewayv2_stage" "ws_messenger_api_stage" {
  api_id      = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  name        = "develop"
  auto_deploy = true
}

# TODO - Refactor the code
### DNS configuration ###
