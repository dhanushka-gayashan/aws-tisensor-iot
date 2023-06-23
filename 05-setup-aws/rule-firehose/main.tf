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
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [aws_kinesis_firehose_delivery_stream.stream.arn]
  }
}

resource "aws_iam_role" "iot_topic_rule" {
  name               = "IotTopicRuleFirehoseRole"
  assume_role_policy = data.aws_iam_policy_document.iot_topic_rule_assume.json
}

resource "aws_iam_role_policy" "iot_topic_rule" {
  name   = "IotTopicRuleFirehosePolicy"
  role   = aws_iam_role.iot_topic_rule.id
  policy = data.aws_iam_policy_document.iot_topic_rule.json
}

# firehose
data "aws_iam_policy_document" "firehose_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.firehouse_landing_bucket.arn,
      "${aws_s3_bucket.firehouse_landing_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "firehose" {
  name               = "IotFirehoseRole"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

resource "aws_iam_role_policy" "firehose" {
  name   = "IotFirehosePolicy"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}

# lambda: notification send
data "aws_iam_policy_document" "notification_lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "notification_lambda_dynamodb" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [
      aws_dynamodb_table.mobile.arn,
      "${aws_dynamodb_table.mobile.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "notification_lambda_sqs" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "kms:Decrypt",
    ]
    resources = values(aws_sqs_queue.firehose)[*].arn
  }
}

data "aws_iam_policy_document" "notification_lambda_logs" {
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

resource "aws_iam_role" "notification_lambda" {
  name               = "IotFirehoseNotificationLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.notification_lambda_assume.json
}

resource "aws_iam_role_policy" "notification_lambda_dynamodb" {
  name   = "IotFirehoseNotificationLambdaDynamodbPolicy"
  role   = aws_iam_role.notification_lambda.id
  policy = data.aws_iam_policy_document.notification_lambda_dynamodb.json
}

resource "aws_iam_role_policy" "notification_lambda_sqs" {
  name   = "IotFirehoseNotificationLambdaSQSPolicy"
  role   = aws_iam_role.notification_lambda.id
  policy = data.aws_iam_policy_document.notification_lambda_sqs.json
}

resource "aws_iam_role_policy" "notification_lambda_logs" {
  name   = "IotFirehoseNotificationLambdaLogsPolicy"
  role   = aws_iam_role.notification_lambda.id
  policy = data.aws_iam_policy_document.notification_lambda_logs.json
}

# lambda: send sms
data "aws_iam_policy_document" "send_sms_lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "send_sms_lambda_sqs" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "kms:Decrypt",
    ]
    resources = [
      aws_sqs_queue.firehose["iot_sms"].arn
    ]
  }
}

data "aws_iam_policy_document" "send_sms_lambda_sns" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "send_sms_lambda_logs" {
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

resource "aws_iam_role" "send_sms_lambda" {
  name               = "IotFirehoseSendSMSLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.send_sms_lambda_assume.json
}

resource "aws_iam_role_policy" "send_sms_lambda_sqs" {
  name   = "IotFirehoseSendSMSLambdaSQSPolicy"
  role   = aws_iam_role.send_sms_lambda.id
  policy = data.aws_iam_policy_document.send_sms_lambda_sqs.json
}

resource "aws_iam_role_policy" "send_sms_lambda_sns" {
  name   = "IotFirehoseSendSMSLambdaSNSPolicy"
  role   = aws_iam_role.send_sms_lambda.id
  policy = data.aws_iam_policy_document.send_sms_lambda_sns.json
}

resource "aws_iam_role_policy" "send_sms_lambda_logs" {
  name   = "IotFirehoseNotificationLambdaLogsPolicy"
  role   = aws_iam_role.send_sms_lambda.id
  policy = data.aws_iam_policy_document.send_sms_lambda_logs.json
}

# lambda: save mobile number
data "aws_iam_policy_document" "save_number_lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "save_number_lambda_dynamodb" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      aws_dynamodb_table.mobile.arn,
    ]
  }
}

data "aws_iam_policy_document" "save_number_lambda_logs" {
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

resource "aws_iam_role" "save_number_lambda" {
  name               = "IotFirehoseSaveNumberLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.save_number_lambda_assume.json
}

resource "aws_iam_role_policy" "save_number_lambda_dynamodb" {
  name   = "IotFirehoseSaveNumberLambdaDynamodbPolicy"
  role   = aws_iam_role.save_number_lambda.id
  policy = data.aws_iam_policy_document.save_number_lambda_dynamodb.json
}

resource "aws_iam_role_policy" "save_number_lambda_logs" {
  name   = "IotFirehoseSaveNumberLambdaLogsPolicy"
  role   = aws_iam_role.save_number_lambda.id
  policy = data.aws_iam_policy_document.save_number_lambda_logs.json
}

# lambda: glue job trigger
data "aws_iam_policy_document" "trigger_lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "trigger_lambda_glue_job" {
  statement {
    effect  = "Allow"
    actions = [
      "glue:StartJobRun",
    ]
    resources = [
      aws_glue_job.firehose.arn
    ]
  }
}

data "aws_iam_policy_document" "trigger_lambda_logs" {
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

resource "aws_iam_role" "trigger_lambda" {
  name               = "IotFirehoseTriggerLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.trigger_lambda_assume.json
}

resource "aws_iam_role_policy" "trigger_lambda_glue_job" {
  name   = "IotFirehoseTriggerLambdaGlueJobPolicy"
  role   = aws_iam_role.trigger_lambda.id
  policy = data.aws_iam_policy_document.trigger_lambda_glue_job.json
}

resource "aws_iam_role_policy" "trigger_lambda_logs" {
  name   = "IotFirehoseTriggerLambdaLogsPolicy"
  role   = aws_iam_role.trigger_lambda.id
  policy = data.aws_iam_policy_document.trigger_lambda_logs.json
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
  name               = "IotFirehoseAPIGatewayRole"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume.json
}

resource "aws_iam_role_policy" "api_gateway" {
  name   = "IotFirehoseAPIGatewayPolicy"
  role   = aws_iam_role.api_gateway.id
  policy = data.aws_iam_policy_document.api_gateway_logs.json
}

# glue job
data "aws_iam_policy_document" "glue_job_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_job_s3" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [
      aws_s3_bucket.firehouse_landing_bucket.arn,
      "${aws_s3_bucket.firehouse_landing_bucket.arn}/*",
      aws_s3_bucket.glue_job_bucket.arn,
      "${aws_s3_bucket.glue_job_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "glue_job_sqs" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "kms:Decrypt",
    ]
    resources = [
      aws_sqs_queue.firehose["iot_notification"].arn
    ]
  }
}

data "aws_iam_policy_document" "glue_job_logs" {
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

resource "aws_iam_role" "glue_job" {
  name               = "IotFirehoseGlueJobRole"
  assume_role_policy = data.aws_iam_policy_document.glue_job_assume.json
}

resource "aws_iam_role_policy" "glue_job_s3" {
  name   = "IotFirehoseGlueJobPolicyS3"
  role   = aws_iam_role.glue_job.id
  policy = data.aws_iam_policy_document.glue_job_s3.json
}

resource "aws_iam_role_policy" "glue_job_sqs" {
  name   = "IotFirehoseGlueJobPolicySQS"
  role   = aws_iam_role.glue_job.id
  policy = data.aws_iam_policy_document.glue_job_sqs.json
}

resource "aws_iam_role_policy" "glue_job_logs" {
  name   = "IotFirehoseGlueJobPolicyLog"
  role   = aws_iam_role.glue_job.id
  policy = data.aws_iam_policy_document.glue_job_logs.json
}


##################
# LANDING BUCKET #
##################

resource "random_id" "firehouse_landing_bucket" {
  byte_length = 8
}

resource "aws_s3_bucket" "firehouse_landing_bucket" {
  bucket = "iot-rule-firehose-landing-bucket-${random_id.firehouse_landing_bucket.hex}"
}


##################
# LANDING BUCKET #
##################

resource "random_id" "glue_job_bucket" {
  byte_length = 8
}

resource "aws_s3_bucket" "glue_job_bucket" {
  bucket = "iot-rule-firehose-glue-job-bucket-${random_id.glue_job_bucket.hex}"
}


#############################
# SYSTEMS MANAGER PARAMETER #
#############################

resource "aws_ssm_parameter" "parameter" {
  for_each = local.ssm_parameters

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
}


##################
# DYNAMODB TABLE #
##################

resource "aws_dynamodb_table" "mobile" {
  name           = local.mobile.name
  billing_mode   = local.mobile.billing_mode
  read_capacity  = local.mobile.read_capacity
  write_capacity = local.mobile.write_capacity
  hash_key       = local.mobile.hash_key

  attribute {
    name = local.mobile.hash_key
    type = "S"
  }

  ttl {
    enabled        = local.mobile.ttl_enable
    attribute_name = local.mobile.ttl_attribute
  }
}


#######
# SQS #
#######

resource "aws_sqs_queue" "firehose" {
  for_each = local.sqs

  name                        = each.value.fifo_queue ? "${each.key}.fifo" : each.key
  delay_seconds               = each.value.delay_seconds
  max_message_size            = each.value.max_message_size
  message_retention_seconds   = each.value.message_retention_seconds
  receive_wait_time_seconds   = each.value.receive_wait_time_seconds
  visibility_timeout_seconds  = each.value.visibility_timeout_seconds
  fifo_queue                  = each.value.fifo_queue
  content_based_deduplication = each.value.content_based_deduplication
  sqs_managed_sse_enabled     = each.value.sqs_managed_sse_enabled
  tags                        = each.value.tags
}


############
# GLUE JOB #
############

# upload job script
resource "aws_s3_object" "glue_job_script" {
  bucket      = aws_s3_bucket.glue_job_bucket.bucket
  key         = "scripts/iot_firehose_job.py"
  source      = "${path.module}/glue_job/process/iot_firehose_job.py"
  source_hash = filemd5("${path.module}/glue_job/process/iot_firehose_job.py")
}

# glue job
resource "aws_glue_job" "firehose" {
  name     = local.glue_job.name
  role_arn = aws_iam_role.glue_job.arn
  command {
    script_location = "s3://${aws_s3_bucket.glue_job_bucket.bucket}/scripts/iot_firehose_job.py"
  }
  glue_version = "4.0"
  timeout      = 600

  default_arguments = {
    "--region"  = local.glue_job.region
    "--bucket"  = local.glue_job.bucket
    "--file"    = "TEST FILE"
    "--sqs_url" = local.glue_job.sqs_url
  }

  execution_property {
    max_concurrent_runs = 200
  }

  number_of_workers = 10
  worker_type       = "Standard"
  max_retries       = 0
}


##########
# LAMBDA #
##########

resource "aws_lambda_function" "firehose" {
  for_each = local.lambda

  function_name                  = each.key
  handler                        = each.value.handler
  runtime                        = each.value.runtime
  role                           = each.value.role
  filename                       = "${path.module}/${each.value.file}"
  source_code_hash               = filebase64sha256("${path.module}/${each.value.file}")
  memory_size                    = each.value.memory
  timeout                        = each.value.timeout
  reserved_concurrent_executions = each.value.concurrency

  environment {
    variables = each.value.env_vars
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = aws_lambda_function.firehose

  name              = "/aws/lambda/${each.value.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "sqs" {
  for_each = {for k, v in local.lambda : k => v.sqs if v.sqs_integration}

  event_source_arn = each.value["arn"]
  enabled          = each.value["enabled"]
  function_name    = each.key
  batch_size       = each.value["batch_size"]

  depends_on = [
    aws_lambda_function.firehose
  ]
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = {for k, v in local.lambda : k => v if v.api_integration}

  statement_id  = "${each.key}IotFirehoseApiIntegration"
  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "s3" {
  for_each = {for k, v in local.lambda : k => v if v.s3_integration}

  statement_id  = "${each.key}IotFirehoseS3Integration"
  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "s3.amazonaws.com"
  source_arn    = each.value.s3.arn
}

resource "aws_s3_bucket_notification" "lambda" {
  for_each = {for k, v in local.lambda : k => v if v.s3_integration}

  bucket = each.value.s3.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.firehose[each.key].arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.s3]
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
resource "aws_api_gateway_rest_api" "iot" {
  name = local.api.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

### resource integration ###
resource "aws_api_gateway_resource" "iot" {
  rest_api_id = aws_api_gateway_rest_api.iot.id
  parent_id   = aws_api_gateway_rest_api.iot.root_resource_id
  path_part   = "mobile"
}

resource "aws_api_gateway_method" "iot" {
  rest_api_id      = aws_api_gateway_rest_api.iot.id
  resource_id      = aws_api_gateway_resource.iot.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "iot" {
  rest_api_id             = aws_api_gateway_rest_api.iot.id
  resource_id             = aws_api_gateway_resource.iot.id
  http_method             = aws_api_gateway_method.iot.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.firehose["IotSaveMobileNumber"].invoke_arn
}

### enable CORS ###
resource "aws_api_gateway_resource" "cors" {
  rest_api_id = aws_api_gateway_rest_api.iot.id
  parent_id   = aws_api_gateway_rest_api.iot.root_resource_id
  path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.iot.id
  resource_id   = aws_api_gateway_resource.cors.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id = aws_api_gateway_rest_api.iot.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "cors" {
  depends_on          = [aws_api_gateway_method.cors]
  rest_api_id         = aws_api_gateway_rest_api.iot.id
  resource_id         = aws_api_gateway_resource.cors.id
  http_method         = aws_api_gateway_method.cors.http_method
  status_code         = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  depends_on          = [aws_api_gateway_integration.cors, aws_api_gateway_method_response.cors]
  rest_api_id         = aws_api_gateway_rest_api.iot.id
  resource_id         = aws_api_gateway_resource.cors.id
  http_method         = aws_api_gateway_method.cors.http_method
  status_code         = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'", # replace with hostname of frontend (CloudFront)
    "method.response.header.Access-Control-Allow-Headers" = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'" # remove or add HTTP methods as needed
  }
}

resource "aws_api_gateway_gateway_response" "response_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.iot.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}

resource "aws_api_gateway_gateway_response" "response_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.iot.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}

### deployment ###
resource "aws_api_gateway_deployment" "iot" {
  rest_api_id = aws_api_gateway_rest_api.iot.id
  triggers    = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.iot.body,
      aws_api_gateway_integration.iot,
      aws_api_gateway_resource.iot,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "iot" {
  rest_api_id   = aws_api_gateway_rest_api.iot.id
  deployment_id = aws_api_gateway_deployment.iot.id
  stage_name    = "prod"
}

### DNS configuration ###
resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name              = var.api_gateway_domain
  regional_certificate_arn = aws_acm_certificate.api_gateway.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate.api_gateway
  ]
}

resource "aws_route53_record" "api_gateway_domain" {
  name    = aws_api_gateway_domain_name.api_gateway_domain.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "api_gateway_domain" {
  api_id      = aws_api_gateway_rest_api.iot.id
  stage_name  = aws_api_gateway_stage.iot.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
}


#####################
# KINESIS FIREHOSE  #
#####################

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  name        = "iot-topic-rule-firehose-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.firehouse_landing_bucket.arn
  }

  depends_on = [
    aws_s3_bucket.firehouse_landing_bucket
  ]
}


##############
# TOPIC RULE #
##############

resource "aws_iot_topic_rule" "iot_topic_rule_firehose" {
  name        = local.rule.name
  description = local.rule.description
  enabled     = local.rule.enabled
  sql         = local.rule.sql
  sql_version = local.rule.sql_version

  firehose {
    delivery_stream_name = aws_kinesis_firehose_delivery_stream.stream.name
    role_arn             = aws_iam_role.iot_topic_rule.arn
  }

  depends_on = [
    aws_kinesis_firehose_delivery_stream.stream
  ]
}