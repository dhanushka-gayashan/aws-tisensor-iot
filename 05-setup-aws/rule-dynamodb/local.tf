locals {
  # raw dynamodb tables
  raw = {
    name = "IOTRawDataTable"
    billing_mode = "PROVISIONED"
    read_capacity = 1
    write_capacity = 1
    hash_key = "timestamp"
    range_key = "type"
    stream_enabled = true
    stream_view_type = "NEW_IMAGE"
    ttl_enable = true
    ttl_attribute = "timestamp"
  }

  # output dynamodb tables
  outputs = {
    temperature = {
      name = "IOTOutputTemperatureTable"
      billing_mode = "PROVISIONED"
      read_capacity = 1
      write_capacity = 1
      hash_key = "uuid"
      range_key = "timestamp"
      ttl_enable = true
      ttl_attribute = "uuid"
    }

    pressure = {
      name = "IOTOutputPressureTable"
      billing_mode = "PROVISIONED"
      read_capacity = 1
      write_capacity = 1
      hash_key = "uuid"
      range_key = "timestamp"
      ttl_enable = true
      ttl_attribute = "uuid"
    }
  }

  # lambda
  lambda = {
    function_name = "IOTDataProcess"
    handler = "main"
    runtime = "go1.x"
    filename = "./lambda/process/process.zip"
    memory_size = 128
    timeout = 180
  }

  # topic rule
  rule = {
    name = "Dynamodb"
    description = "Iot Topic Rule for Dynamodb"
    enabled = false
    sql = "SELECT * FROM 'aws/sensorTag'"
    sql_version = "2016-03-23"
  }
}