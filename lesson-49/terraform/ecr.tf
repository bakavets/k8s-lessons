resource "aws_ecr_repository" "template" {
  name                 = "demo-app"
  image_tag_mutability = "IMMUTABLE"
}
