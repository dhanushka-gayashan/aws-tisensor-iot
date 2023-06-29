output "api_gateway_url" {
  value = module.rule-firehose.api_gateway_uri
}

output "ws_api_gateway_url" {
  value = module.rule-kinesis.ws_api_gateway_uri
}

output "container_registry_url" {
  value       = module.rule-kinesis.container_registry_url
}