output "api_gateway_uri" {
  value = "${aws_api_gateway_deployment.iot.invoke_url}${aws_api_gateway_stage.iot.stage_name}"
}