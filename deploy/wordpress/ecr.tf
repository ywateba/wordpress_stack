# ECR registry 


resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo" # Replace with your desired repository name
  image_tag_mutability = "MUTABLE" # Change as needed
  image_scanning_configuration {
    scan_on_push = true
  }
}