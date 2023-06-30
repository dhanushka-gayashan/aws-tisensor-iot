locals {
  # dynamodb table
  connection = {
    name           = "IOTWSConnectionTable"
    billing_mode   = "PROVISIONED"
    read_capacity  = 1
    write_capacity = 1
    hash_key       = "ConnectionID"
    ttl_enable     = true
    ttl_attribute  = "ExpirationTime"
  }

  # lambda
  ws_connection = {
    name        = "IotWSConnection"
    file        = "./lambda/connection/connection.zip"
    role        = aws_iam_role.connection.arn
    runtime     = "go1.x"
    handler     = "main"
    memory      = 128
    timeout     = 180
    concurrency = 3
    env_vars    = {
      "API_GATEWAY_ENDPOINT" = "https://${aws_apigatewayv2_api.ws_iot.id}.execute-api.${var.region}.amazonaws.com/${aws_apigatewayv2_stage.ws_iot.id}"
      "DYNAMODB_TABLE"       = aws_dynamodb_table.connection.id
    }
  }

  # container registry
  ecr = {
    name                 = "mediator"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
  }

  # fargate
  cluster = {
    name = "iot-mediator-cluster"
  }

  task = {
    family                   = "iot-mediator-task"
    cpu                      = "1024"
    memory                   = "2048"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    name                     = "iot-mediator-image"
    image                    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/mediator:latest"
    essential                = true
  }

  service = {
    name             = "iot-mediator-service"
    desired_count    = 1
    launch_type      = "FARGATE"
    subnets          = slice(data.aws_subnets.default.ids, 0, 2)
    assign_public_ip = false
  }

  trigger = {
    name            = "iot-ecr-deployment"
    description     = "Triggers when a new image is pushed to ECR"
    repository-name = ["mediator"]
  }

  # api gateway
  api = {
    name = "iot_ws_api_gateway"
  }

  # kinesis
  kinesis = {
    name             = "iot-topic-rule-kinesis-stream"
    shard_count      = 1
    retention_period = 24
    stream_mode      = "PROVISIONED"
  }

  # topic rule
  rule = {
    name          = "Kinesis"
    description   = "Iot Topic Rule for Kinesis"
    enabled       = var.enable
    sql           = "SELECT device_label, pressure, temperature, humidity FROM 'aws/sensorTag'"
    sql_version   = "2016-03-23"
    partition_key = "device_label"
  }
}