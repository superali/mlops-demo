resource "aws_api_gateway_rest_api" "ai_assistant_api" {
  name        = "ai-assistant-api"
  description = "API Gateway for AI Assistant"
}


resource "aws_api_gateway_resource" "ai_assistant_resource" {
  rest_api_id = aws_api_gateway_rest_api.ai_assistant_api.id
  parent_id   = aws_api_gateway_rest_api.ai_assistant_api.root_resource_id
  path_part   = "assistant" #  The path after the API Gateway URL (e.g., /assistant)
}


resource "aws_api_gateway_method" "ai_assistant_method" {
  rest_api_id   = aws_api_gateway_rest_api.ai_assistant_api.id
  resource_id   = aws_api_gateway_resource.ai_assistant_resource.id
  http_method   = "POST"
  authorization = "NONE"


}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGWInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_assistant_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ai_assistant_api.execution_arn}/*/*" #  Important for security
}

# API Gateway Integration
resource "aws_api_gateway_integration" "ai_assistant_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ai_assistant_api.id
  resource_id             = aws_api_gateway_resource.ai_assistant_resource.id
  http_method             = aws_api_gateway_method.ai_assistant_method.http_method
  integration_http_method = "POST"      #  Must be POST for Lambda proxy integration
  type                    = "AWS_PROXY" # Use AWS_PROXY for Lambda integration
  uri                     = aws_lambda_function.ai_assistant_lambda.invoke_arn
  # content_handling = "CONVERT_TO_TEXT" #optional
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "ai_assistant_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ai_assistant_api.id
  stage_name  = "prod" #  The stage (e.g., "prod", "dev", "test")
  depends_on = [aws_api_gateway_integration.ai_assistant_integration] 
}
# API Gateway Stage 
resource "aws_api_gateway_stage" "ai_assistant_stage" {
  rest_api_id   = aws_api_gateway_rest_api.ai_assistant_api.id
  deployment_id = aws_api_gateway_deployment.ai_assistant_deployment.id
  stage_name    = "prod"
}
