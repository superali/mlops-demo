# Output the API Gateway endpoint
output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.ai_assistant_deployment.invoke_url}/assistant" # corrected output
  description = "The API Gateway endpoint URL"
}
