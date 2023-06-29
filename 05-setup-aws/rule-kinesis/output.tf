output "ws_api_gateway_uri" {
  value = "${aws_apigatewayv2_stage.ws_iot.invoke_url}${aws_apigatewayv2_stage.ws_iot.name}"
}

output "container_registry_url" {
  description = "The url of the mediator ECR repository"
  value       = aws_ecr_repository.mediator.repository_url
}