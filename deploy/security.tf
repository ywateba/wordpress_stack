provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "wordpress-bucket" # Replace with your desired S3 bucket name
  acl    = "private" # You can adjust the ACL as needed for your security requirements
}

resource "aws_s3_bucket_object" "private_key" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "wordpress-keypair"
  source       = "./wordpress-keypair" # Replace with the path to your private key
  content_type = "application/octet-stream"
  etag         = filemd5("./wordpress-keypair") # Optional but recommended
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "wordpress-keypair"
  public_key = file("./wordpress-keypair.pub") # Use the path to your public key
}


resource "null_resource" "run_local_script" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -t rsa -b 2048 -f wordpress-keypair "
  }
}