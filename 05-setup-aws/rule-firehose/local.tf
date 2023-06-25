locals {
  # system manager parameters
  ssm_parameters = {
    pressure = {
      name = "/iot/firehose/pressure"
      description = "maximum air pressure"
      type = "String"
      value = "13"
    }

    temperature = {
      name = "/iot/firehose/temperature"
      description = "maximum air temperature"
      type = "String"
      value = "13"
    }
  }

  # dynamodb tables
  mobile = {
    name             = "IOTMobileNumbersTable"
    billing_mode     = "PROVISIONED"
    read_capacity    = 1
    write_capacity   = 1
    hash_key         = "mobile"
    ttl_enable       = true
    ttl_attribute    = "mobile"
  }

  # sqs queues
  sqs = {
    iot_notification = {
      delay_seconds               = 0
      max_message_size            = 2048
      message_retention_seconds   = 86400
      receive_wait_time_seconds   = 10
      visibility_timeout_seconds  = 180
      fifo_queue                  = true
      content_based_deduplication = true
      sqs_managed_sse_enabled     = true
      tags                        = {}
    }

    iot_sms = {
      delay_seconds               = 0
      max_message_size            = 2048
      message_retention_seconds   = 86400
      receive_wait_time_seconds   = 10
      visibility_timeout_seconds  = 180
      fifo_queue                  = true
      content_based_deduplication = true
      sqs_managed_sse_enabled     = true
      tags                        = {}
    }
  }

  # lambdas
  lambda = {
    IotNotification = {
      file            = "./lambda/queue_notification/notification.zip"
      role            = aws_iam_role.notification_lambda.arn
      runtime         = "go1.x"
      handler         = "main"
      memory          = 128
      timeout         = 180
      concurrency     = 3
      api_integration = false
      sqs_integration = true
      sqs             = {
        arn         = aws_sqs_queue.firehose["iot_notification"].arn
        enabled     = true
        batch_size  = 1
      }
      s3_integration  = false
      s3 = {}
      env_vars        = {
        READ_SQS_URL = aws_sqs_queue.firehose["iot_notification"].url
        WRITE_SQS_URL = aws_sqs_queue.firehose["iot_sms"].url
        TABLE = aws_dynamodb_table.mobile.name
        STATUS = "HIGH PRESSURE"
      }
    }

    IotSendSms = {
      file            = "./lambda/send_sms/sms.zip"
      role            = aws_iam_role.send_sms_lambda.arn
      runtime         = "go1.x"
      handler         = "main"
      memory          = 128
      timeout         = 180
      concurrency     = 3
      api_integration = false
      sqs_integration = true
      sqs             = {
        arn         = aws_sqs_queue.firehose["iot_sms"].arn
        enabled     = true
        batch_size  = 1
      }
      s3_integration  = false
      s3 = {}
      env_vars        = {
        READ_SQS_URL = aws_sqs_queue.firehose["iot_sms"].url
      }
    }

    IotSaveMobileNumber = {
      file            = "./lambda/save_mobile_number/mobile.zip"
      role            = aws_iam_role.save_number_lambda.arn
      runtime         = "go1.x"
      handler         = "main"
      memory          = 128
      timeout         = 180
      concurrency     = 3
      api_integration = true
      sqs_integration = false
      sqs             = {}
      s3_integration  = false
      s3 = {}
      env_vars        = {
        TABLE = aws_dynamodb_table.mobile.name
      }
    }

    IotGlueJobTrigger = {
      file            = "./lambda/glue_job_trigger/trigger.zip"
      role            = aws_iam_role.trigger_lambda.arn
      runtime         = "go1.x"
      handler         = "main"
      memory          = 128
      timeout         = 180
      concurrency     = 3
      api_integration = false
      sqs_integration = false
      sqs             = {}
      s3_integration  = true
      s3 = {
        id = aws_s3_bucket.firehouse_landing_bucket.id
        arn = aws_s3_bucket.firehouse_landing_bucket.arn
      }
      env_vars        = {
        JOB_NAME = aws_glue_job.firehose.name
      }
    }
  }

  # api gateway
  api = {
    name = "iot_api_gateway"
  }

  # glue job
  glue_job = {
    name = "iot_firehose_glue_job"
    region = var.region
    bucket = aws_s3_bucket.firehouse_landing_bucket.bucket
    sqs_url = aws_sqs_queue.firehose["iot_notification"].url
  }

  # topic rule
  rule = {
    name        = "Firehose"
    description = "Iot Topic Rule for Firehose"
    enabled     = var.enable
    sql         = "SELECT * FROM 'aws/sensorTag'"
    sql_version = "2016-03-23"
  }
}