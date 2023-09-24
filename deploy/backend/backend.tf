# Define your AWS provider configuration


terraform {
 

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.40"
    }  

  }
}
provider "aws" {
  region = "us-east-1" # Update with your desired AWS region
  profile = "perso"
}

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = "ary_wordpress"
  ec
}
