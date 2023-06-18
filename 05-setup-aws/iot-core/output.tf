##################
# IOT-CORE THING #
##################

output "thing_name" {
  value = aws_iot_thing.thing.name
}

#####################
# IOT-CORE ENDPOINT #
#####################

output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}