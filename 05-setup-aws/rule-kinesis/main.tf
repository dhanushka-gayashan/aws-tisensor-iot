########
# DATA #
########

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}


#############
# IAM ROlES #
#############

# iot topic rule
data "aws_iam_policy_document" "iot_topic_rule_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iot_topic_rule" {
  statement {
    effect  = "Allow"
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
    ]
    resources = [aws_kinesis_stream.stream.arn]
  }
}

resource "aws_iam_role" "iot_topic_rule" {
  name               = "IotTopicRuleKinesisRole"
  assume_role_policy = data.aws_iam_policy_document.iot_topic_rule_assume.json
}

resource "aws_iam_role_policy" "iot_topic_rule" {
  name   = "IotTopicRuleKinesisPolicy"
  role   = aws_iam_role.iot_topic_rule.id
  policy = data.aws_iam_policy_document.iot_topic_rule.json
}

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
      "${aws_apigatewayv2_stage.ws_iot.execution_arn}/*/*/*"
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

# fargate task
data "aws_iam_policy_document" "fargate" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "fargate_ecs_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "fargate_kinesis_policy" {
  statement {
    actions = [
      "kinesis:Get*",
      "kinesis:DescribeStreamSummary"
    ]

    resources = [
      aws_kinesis_stream.stream.arn
    ]
  }
}

data "aws_iam_policy_document" "fargate_kinesis_all_policy" {
  statement {
    actions = [
      "kinesis:ListStreams"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "fargate_log_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_role" "fargate" {
  name               = "IotFargateExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.fargate.json
}

resource "aws_iam_role_policy" "fargate_ecs" {
  name   = "IotFargateEcsPolicy"
  role   = aws_iam_role.fargate.id
  policy = data.aws_iam_policy_document.fargate_ecs_policy.json
}

resource "aws_iam_role_policy" "fargate_kinesis" {
  name   = "IotFargateKinesisPolicy"
  role   = aws_iam_role.fargate.id
  policy = data.aws_iam_policy_document.fargate_kinesis_policy.json
}

resource "aws_iam_role_policy" "fargate_kinesis_all" {
  name   = "IotFargateKinesisAllPolicy"
  role   = aws_iam_role.fargate.id
  policy = data.aws_iam_policy_document.fargate_kinesis_all_policy.json
}

resource "aws_iam_role_policy" "fargate_log" {
  name   = "IotFargateLogPolicy"
  role   = aws_iam_role.fargate.id
  policy = data.aws_iam_policy_document.fargate_log_policy.json
}


##################
# DYNAMODB TABLE #
##################

resource "aws_dynamodb_table" "connection" {
  name           = local.connection.name
  billing_mode   = local.connection.billing_mode
  read_capacity  = local.connection.read_capacity
  write_capacity = local.connection.write_capacity
  hash_key       = local.connection.hash_key

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
  source_arn    = "${aws_apigatewayv2_api.ws_iot.execution_arn}/*/*"
}


###########################
# API GATEWAY CERTIFICATE #
###########################
resource "aws_acm_certificate" "api_gateway" {
  domain_name       = var.api_gateway_domain
  validation_method = "DNS"
}

resource "aws_route53_record" "api_gateway" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "api_gateway" {
  certificate_arn         = aws_acm_certificate.api_gateway.arn
  validation_record_fqdns = [for record in aws_route53_record.api_gateway : record.fqdn]
}


###############
# API GATEWAY #
###############

### api gateway ###
resource "aws_apigatewayv2_api" "ws_iot" {
  name                       = local.api.name
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

### resource integration ###
resource "aws_apigatewayv2_integration" "ws_iot" {
  api_id                    = aws_apigatewayv2_api.ws_iot.id
  integration_type          = "AWS_PROXY"
  integration_uri           = aws_lambda_function.connection.invoke_arn
  credentials_arn           = aws_iam_role.api_gateway.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_integration_response" "ws_iot" {
  api_id                   = aws_apigatewayv2_api.ws_iot.id
  integration_id           = aws_apigatewayv2_integration.ws_iot.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route" "ws_iot_default" {
  api_id    = aws_apigatewayv2_api.ws_iot.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.ws_iot.id}"
}

resource "aws_apigatewayv2_route_response" "ws_iot_default" {
  api_id             = aws_apigatewayv2_api.ws_iot.id
  route_id           = aws_apigatewayv2_route.ws_iot_default.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_iot_connect" {
  api_id    = aws_apigatewayv2_api.ws_iot.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_iot.id}"
}

resource "aws_apigatewayv2_route_response" "ws_iot_connect" {
  api_id             = aws_apigatewayv2_api.ws_iot.id
  route_id           = aws_apigatewayv2_route.ws_iot_connect.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_iot_disconnect" {
  api_id    = aws_apigatewayv2_api.ws_iot.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_iot.id}"
}

resource "aws_apigatewayv2_route_response" "ws_iot_disconnect" {
  api_id             = aws_apigatewayv2_api.ws_iot.id
  route_id           = aws_apigatewayv2_route.ws_iot_disconnect.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_iot_chat" {
  api_id    = aws_apigatewayv2_api.ws_iot.id
  route_key = "CHAT"
  target    = "integrations/${aws_apigatewayv2_integration.ws_iot.id}"
}

resource "aws_apigatewayv2_route_response" "ws_iot_chat" {
  api_id             = aws_apigatewayv2_api.ws_iot.id
  route_id           = aws_apigatewayv2_route.ws_iot_chat.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_iot_broadcast" {
  api_id    = aws_apigatewayv2_api.ws_iot.id
  route_key = "BROADCAST"
  target    = "integrations/${aws_apigatewayv2_integration.ws_iot.id}"
}

resource "aws_apigatewayv2_route_response" "ws_iot_broadcast" {
  api_id             = aws_apigatewayv2_api.ws_iot.id
  route_id           = aws_apigatewayv2_route.ws_iot_broadcast.id
  route_response_key = "$default"
}

### deployment and stage ###
resource "aws_apigatewayv2_stage" "ws_iot" {
  api_id      = aws_apigatewayv2_api.ws_iot.id
  name        = "prod"
  auto_deploy = true
}

### DNS configuration ###
resource "aws_apigatewayv2_domain_name" "ws_iot" {
  domain_name = var.api_gateway_domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_gateway.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "ws_iot" {
  name    = aws_apigatewayv2_domain_name.ws_iot.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.ws_iot.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.ws_iot.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "ws_iot" {
  api_id      = aws_apigatewayv2_api.ws_iot.id
  domain_name = aws_apigatewayv2_domain_name.ws_iot.id
  stage       = aws_apigatewayv2_stage.ws_iot.id
}


######################
# CONTAINER REGISTRY #
######################

resource "aws_ecr_repository" "mediator" {
  name                 = local.ecr.name
  image_tag_mutability = local.ecr.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = local.ecr.scan_on_push
  }
}

####################
# FARGATE INSTANCE #
####################

resource "aws_ecs_cluster" "mediator" {
  name = "iot_mediator"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#resource "aws_ecs_task_definition" "mediator" {
#  family                   = local.task.family
#  cpu                      = local.task.cpu
#  memory                   = local.task.memory
#  network_mode             = local.task.network_mode
#  requires_compatibilities = local.task.requires_compatibilities
#  execution_role_arn       = aws_iam_role.fargate.arn
#  task_role_arn            = aws_iam_role.fargate.arn
#
#  container_definitions = jsonencode([
#    {
#      name      = local.task.name
#      image     = local.task.image
#      essential = local.task.essential
#    }
#  ])
#}
#
#resource "aws_ecs_service" "mediator" {
#  name            = local.service.name
#  cluster         = aws_ecs_cluster.mediator.id
#  task_definition = aws_ecs_task_definition.mediator.arn
#  desired_count   = local.service.desired_count
#  launch_type     = local.service.launch_type
#
#  network_configuration {
#    subnets          = local.service.subnets
#    assign_public_ip = true
#    security_groups  = [data.aws_security_group.default.id]
#  }
#}


##################
# KINESIS STREAM #
##################

resource "aws_kinesis_stream" "stream" {
  name             = local.kinesis.name
  shard_count      = local.kinesis.shard_count
  retention_period = local.kinesis.retention_period

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = local.kinesis.stream_mode
  }
}


##############
# TOPIC RULE #
##############

resource "aws_iot_topic_rule" "kinesis_rule" {
  name        = local.rule.name
  description = local.rule.description
  enabled     = local.rule.enabled
  sql         = local.rule.sql
  sql_version = local.rule.sql_version

  kinesis {
    role_arn      = aws_iam_role.iot_topic_rule.arn
    stream_name   = aws_kinesis_stream.stream.name
    partition_key = local.rule.partition_key
  }
}
