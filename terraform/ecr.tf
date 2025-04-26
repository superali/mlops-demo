resource "aws_ecr_repository" "ai_assistant_ecr" {
  name                 = "ai-assistant-repository"
  image_tag_mutability = "MUTABLE" 
}
 
