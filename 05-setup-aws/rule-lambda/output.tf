output "ws_api_gateway_uri" {
  value = "${aws_apigatewayv2_stage.ws_iot.invoke_url}${aws_apigatewayv2_stage.ws_iot.name}"
}