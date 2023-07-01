locals {
  # grafana
  grafana_user = {
    email        = "dhanukdg@gmail.com"
    user_name    = "grafana"
    display_name = "Grafana Admin"
    given_name   = "Grafana"
    family_name  = "Admin"
  }

  grafana_workspace = {
    name                     = "IotSensorData"
    account_access_type      = "CURRENT_ACCOUNT"
    data_sources             = ["TIMESTREAM"]
    authentication_providers = ["AWS_SSO"]
    permission_type          = "SERVICE_MANAGED"
  }

  # timestream
  database = {
    name = "iot"
  }

  table = {
    name = "sensor"
    memory_retention_hours = 1
    magnetic_retention_days = 1
  }


  # topic rule
  rule = {
    name        = "Timestream"
    description = "Iot Topic Rule for Timestream"
    enabled     = var.enable
    sql         = "SELECT pressure, accelerometer, gyroscope, magnetometer, temperature, humidity FROM 'aws/sensorTag'"
    sql_version = "2016-03-23"
  }
}