locals {
  # timestream database
  database = {
    name = "iot"
  }

  table = {
    name = "sensor"
  }

  #

  # topic rule
  rule = {
    name        = "Timestream"
    description = "Iot Topic Rule for Timestream"
    enabled     = var.enable
    sql         = "SELECT * FROM 'aws/sensorTag'"
    sql_version = "2016-03-23"
  }
}