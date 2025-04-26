

# resource "aws_lambda_layer_version" "ai_assistant_lambda" {
#   filename   = "${path.module}/ai-assitant-layer.zip"
#   layer_name = "ai-assitant-layer"

#   compatible_runtimes = ["python3.9"]
# }
# resource "aws_lambda_layer_version" "ai_assistant_lambda2" {
#   filename   = "${path.module}/ai-assitant-layer2.zip"
#   layer_name = "ai-assitant-layer2"

#   compatible_runtimes = ["python3.9"]
# }
# resource "aws_lambda_layer_version" "ai_assistant_lambda3" {
#   filename   = "${path.module}/ai-assitant-layer3.zip"
#   layer_name = "ai-assitant-layer3"

#   compatible_runtimes = ["python3.9"]
# }
# data "archive_file" "ai_assistant_code" {

#   type        = "zip"
#   source_file = "../ai-assistant.py"
#   output_path = "${path.module}/ai-assistant.zip"
# }
resource "aws_lambda_function" "ai_assistant_lambda" {
  function_name    = "ai-assistant"
  image_uri = "${aws_ecr_repository.ai_assistant_ecr.repository_url}:latest"
  role      = aws_iam_role.lambda_execution_role.arn

  package_type = "Image" 
  timeout = 300

 
  environment {
    variables = {
      ENVIRONMENT       = "production"
      OPENAI_API_KEY    = var.OPENAI_API_KEY
      ANTHROPIC_API_KEY = var.ANTHROPIC_API_KEY
      # Add any other environment variables your AI assistant needs
    }
  }
}
 

